// lib/features/cart/screens/cart_screen.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/extensions/double_extension.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/booking/view/screen/location_search_screen.dart';
import 'package:starter_codes/features/booking/view/screen/map_picker_screen.dart';
import 'package:starter_codes/features/payment/view/store_payment_screen.dart';
import 'package:starter_codes/features/store/data/store_service.dart';
import 'package:starter_codes/features/store/model/cart_item_model.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/model/store_payment_argument_model.dart';
import 'package:starter_codes/features/store/view/widget/cart_item_card.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/empty_content.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/core/utils/app_logger.dart';

final appLoggerProvider = Provider((ref) => const AppLogger(CartScreen)); 


class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  Future<void> _showLocationSelectionOptions() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.search, color: AppColors.primary),
                title: const Text('Search for location',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final LocationModel? selectedLocation = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LocationSearchScreen(isPickupLocation: false),
                    ),
                  );
                  if (selectedLocation != null) {
                    ref
                        .read(cartProvider.notifier)
                        .setDropOffLocation(selectedLocation);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.map, color: AppColors.primary),
                title: const Text('Pick from map',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final LocationModel? pickedLocation = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MapPickerScreen(),
                    ),
                  );
                  if (pickedLocation != null) {
                    ref
                        .read(cartProvider.notifier)
                        .setDropOffLocation(pickedLocation);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleProceedToPayment() async {
    final appLogger = ref.read(appLoggerProvider);
    final cartState = ref.read(cartProvider); // Use read as we are performing an action

    final cartProducts = cartState.products; // This is List<StoreProduct>
    final dropOffLocation = cartState.dropOffLocation;
    final selectedDeliveryType = cartState.deliveryType;
    final currentUser = ref.read(userProvider);

    // Basic validation
    if (cartProducts.isEmpty) {
      _showSnackbar('Your cart is empty.');
      return;
    }
    if (dropOffLocation == null) {
      _showSnackbar('Please add a drop-off location.');
      return;
    }
    if (selectedDeliveryType.isEmpty) {
      _showSnackbar('Please select a delivery type.');
      return;
    }
    if (currentUser == null) {
      _showSnackbar('User information is missing. Please log in again.');
      return;
    }

    double subtotal = cartProducts.fold(0.0, (sum, item) => sum + (item.price * (item.quantity ?? 0)));

    final AsyncValue<double> deliveryFeeAsync = ref.read(
      deliveryFeeProvider(DeliveryFeeParams(
        dropOffLocation: dropOffLocation,
        products: cartProducts,
        deliveryType: selectedDeliveryType,
      )),
    );

    double deliveryFee;
    if (deliveryFeeAsync.isLoading) {
      _showSnackbar('Please wait while delivery fee is calculated.');
      return;
    } else if (deliveryFeeAsync.hasError) {
      _showSnackbar('Error calculating delivery fee. Please try again.');
      appLogger.e('Error getting delivery fee for payment: ${deliveryFeeAsync.error}', error: deliveryFeeAsync.error, stackTrace: deliveryFeeAsync.stackTrace);
      return;
    } else {
      deliveryFee = deliveryFeeAsync.value!;
    }

    // Determine the store ID and Name
    final String? storeId = cartProducts.isNotEmpty ? cartProducts.first.store : '';
    final String storeName = ref.watch(currentStoreProvider)!.name ?? '';

    if (storeId == null || storeId.isEmpty) {
      _showSnackbar('Unable to determine store for the order.');
      appLogger.e('No store ID found for products in cart.');
      return;
    }

    // Create CartItem list for StorePaymentArguments
    final List<CartItem> cartItemsForPayment = cartProducts.map((p) => CartItem(product: p, quantity: p.quantity ?? 1)).toList();


    appLogger.d('Navigating to StorePaymentScreen with total amount: ${subtotal + deliveryFee}');

    // Navigate to StorePaymentScreen and wait for result
    final bool? paymentSuccess = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (context) => StorePaymentScreen(
          arguments: StorePaymentArguments(
            state: "",
            storeId: storeId,
            storeName: storeName,
            cartItems: cartItemsForPayment, // Pass the mapped list
            totalProductAmount: subtotal,
            deliveryFee: deliveryFee,
            selectedDropoffLocation: dropOffLocation,
            formattedDropoffAddress: dropOffLocation.formattedAddress!,
            deliveryType: selectedDeliveryType,
            orderType: 'delivery', // Adjust as per your actual order type logic ('delivery' or 'pickup')
          ),
        ),
      ),
    );

    // This part will now be handled inside StorePaymentScreen
    // StorePaymentScreen will handle order creation and navigation to success screen
    // based on the result of the WebView payment.
    // The pop(true/false) from StorePaymentScreen will control this part.
    if (paymentSuccess == true) {
      appLogger.i('Payment successful and order process completed on StorePaymentScreen.');
      // The StorePaymentScreen already navigates to OrderSuccessScreen and clears stack.
      // So no further action needed here on success.
    } else {
      appLogger.w('Payment failed or cancelled on StorePaymentScreen.');
      // Keep user on cart screen or pop to a more appropriate screen
      // _showSnackbar('Payment process was not completed.'); // Already shown by StorePaymentScreen
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLogger = ref.read(appLoggerProvider);

    final cartState = ref.watch(cartProvider);
    final cartItems = cartState.products;
    final dropOffLocation = cartState.dropOffLocation;
    final selectedDeliveryType = cartState.deliveryType;

    appLogger.d('CartScreen: Build method called.');
    appLogger.d('   Cart Items Count: ${cartItems.length}');
    appLogger.d('   Drop-off Location (from CartState): ${dropOffLocation?.formattedAddress ?? 'NULL'}');
    appLogger.d('   Selected Delivery Type (from CartState): $selectedDeliveryType');

    final deliveryFeeParams = DeliveryFeeParams(
      dropOffLocation: dropOffLocation,
      products: cartItems,
      deliveryType: selectedDeliveryType,
    );

    appLogger.d('   DeliveryFeeParams created:');
    appLogger.d('     dropOffLocation: ${deliveryFeeParams.dropOffLocation?.formattedAddress ?? 'N/A'}');
    appLogger.d('     products count: ${deliveryFeeParams.products.length}');
    appLogger.d('     deliveryType: ${deliveryFeeParams.deliveryType}');
    appLogger.d('     Params hashCode: ${deliveryFeeParams.hashCode}');

    final AsyncValue<double> deliveryFeeAsync = ref.watch(
      deliveryFeeProvider(deliveryFeeParams),
    );

    double subtotal = cartItems.fold(
        0.0, (sum, item) => sum + (item.price * (item.quantity ?? 0)));

    double deliveryFee = deliveryFeeAsync.when(
      data: (fee) => fee,
      loading: () {
        appLogger.d('Delivery Fee: Loading...');
        return 0.0;
      },
      error: (e, s) {
        appLogger.e('Delivery Fee: Error in AsyncValue.when: $e', error: e, stackTrace: s);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Error calculating delivery fee. Check logs.')),
          );
        });
        return 0.0;
      },
    );
    appLogger.d('Delivery Fee (resolved): ₦$deliveryFee');

    double total = subtotal + deliveryFee;

    return Scaffold(
      appBar:  MiniAppBar(
        title: 'Cart',
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: EmptyContent(
                      contentText: 'Your cart is empty!',
                    icon:CupertinoIcons.cart,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemCard(
                        product: item,
                        onQuantityChanged: (newQuantity) {
                          if (newQuantity > (item.quantity ?? 0)) {
                            ref.read(cartProvider.notifier).addProduct(item);
                          } else if (newQuantity < (item.quantity ?? 0)) {
                            ref.read(cartProvider.notifier).removeProduct(item);
                          }
                        },
                        onRemoveCompletely: (productToRemove) {
                          ref
                              .read(cartProvider.notifier)
                              .removeProductCompletely(productToRemove);
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LocationInput(
              hintText:
                  dropOffLocation?.formattedAddress ?? 'Add drop-off location',
              icon: Icons.location_on_outlined,
              onTap: _showLocationSelectionOptions,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap.h10,
                  Row(
                    children: [
                      Expanded(
                        child: _buildDeliveryTypeButton(
                          label: 'Regular',
                          value: 'regular',
                          groupValue: selectedDeliveryType,
                          onChanged: (value) {
                            ref.read(cartProvider.notifier).setDeliveryType(value);
                          },
                        ),
                      ),
                      Gap.w10,
                      Expanded(
                        child: _buildDeliveryTypeButton(
                          label: 'Express',
                          value: 'express',
                          groupValue: selectedDeliveryType,
                          onChanged: (value) {
                            ref.read(cartProvider.notifier).setDeliveryType(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildCartSummary(
            subtotal: subtotal,
            total: total,
            isLoadingDeliveryFee: deliveryFeeAsync.isLoading,
            deliveryFee: deliveryFee,
          ),
          Gap.h16,
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cartItems.isEmpty ||
                        dropOffLocation == null ||
                        deliveryFeeAsync.isLoading // Disable if delivery fee is loading
                    ? null
                    : _handleProceedToPayment, // Call the new method
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: deliveryFeeAsync.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Proceed to Payment',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDeliveryTypeButton({
    required String label,
    required String value,
    required String groupValue,
    required ValueChanged<String> onChanged,
  }) {
    final bool isSelected = (value == groupValue);
    return OutlinedButton(
      onPressed: () => onChanged(value),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey[700]!,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildCartSummary({
    required double subtotal,
    required double total,
    required bool isLoadingDeliveryFee,
    required double deliveryFee,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSummaryRow('Sub total', subtotal.toMoney(),
              isBold: false),
          _buildSummaryRow(
              'Delivery Fee',
              isLoadingDeliveryFee
                  ? 'Calculating...'
                  : deliveryFee.toMoney(),
              isBold: false),
          Divider(height: 20, color: Colors.grey[300]),
          _buildSummaryRow('Total', total.toMoney(),
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isBold ? Colors.black : Colors.grey[700],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// LocationInput, DeliveryFeeParams, and deliveryFeeProvider remain unchanged
// ... (Your existing code for these classes) ...
class LocationInput extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final VoidCallback onTap;

  const LocationInput({
    super.key,
    required this.hintText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            Gap.w10,
            Expanded(
              child: Text(
                hintText,
                style: TextStyle(color: Colors.grey[400]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




// --- Delivery Fee Provider (with even more internal logging) ---
class DeliveryFeeParams extends Equatable {
  final LocationModel? dropOffLocation;
  final List<StoreProduct> products;
  final String deliveryType;

  const DeliveryFeeParams({
    required this.dropOffLocation,
    required this.products,
    required this.deliveryType,
  });

  // Use equatable for robust equality
  @override
  List<Object?> get props => [dropOffLocation, products, deliveryType];
}

final deliveryFeeProvider = FutureProvider.family<double, DeliveryFeeParams>(
  (ref, params) async {
    final appLogger = ref.read(appLoggerProvider); // Get the logger

    appLogger.d('>>> DELIVERY FEE PROVIDER FUNCTION STARTED <<<');
    appLogger.d('  Params Hash Code RECEIVED: ${params.hashCode}'); // This should match what's logged in CartScreen build
    appLogger.d('  Drop-off Location: ${params.dropOffLocation?.formattedAddress ?? 'N/A'}');
    appLogger.d('  Delivery Type: ${params.deliveryType}');
    appLogger.d('  Number of Products: ${params.products.length}');

    final storeService = ref.read(storeServiceProvider);

    final dropOffLocation = params.dropOffLocation;
    final cartProducts = params.products;
    final deliveryType = params.deliveryType;

    if (dropOffLocation == null) {
      appLogger.w('DeliveryFeeProvider: dropOffLocation is null. Returning 0.0.');
      return 0.0;
    }
    if (cartProducts.isEmpty) {
      appLogger.w('DeliveryFeeProvider: cartProducts is empty. Returning 0.0.');
      return 0.0;
    }

    final storeId = cartProducts.first.store;
    if (storeId == null || storeId.isEmpty) { // Added .isEmpty check
      appLogger.e('DeliveryFeeProvider: Store ID is null or empty for products in cart. Cannot calculate fee.');
      // Optional: Log the first product to inspect its 'store' field
      return 0.0;
    }
    appLogger.d('  Extracted Store ID: $storeId');

    try {
      appLogger.d('  Calling storeService.fetchShoppingDeliveryFee...');
      final fee = await storeService.fetchShoppingDeliveryFee(
        storeId: storeId,
        dropoffLocation: dropOffLocation,
        deliveryType: deliveryType,
      );
      appLogger.d('  Delivery Fee calculated: ₦$fee');
      appLogger.d('<<< DELIVERY FEE PROVIDER FUNCTION ENDED (SUCCESS) >>>');
      return fee;
    } catch (e, st) {
      appLogger.e('Failed to fetch delivery fee in service call: $e', error: e, stackTrace: st);
      appLogger.d('<<< DELIVERY FEE PROVIDER FUNCTION ENDED (ERROR) >>>');
      return 0.0;
    }
  },
);