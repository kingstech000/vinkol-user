// lib/features/cart/screens/cart_screen.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/core/extensions/double_extension.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/features/profile/view_model/personal_info_view_model.dart';
import 'package:starter_codes/features/store/data/store_service.dart';
import 'package:starter_codes/features/store/model/store_request_model.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/cart_item_card.dart';
import 'package:starter_codes/features/booking/view/screen/location_search_screen.dart';
import 'package:starter_codes/features/store/view_model/order_view_model.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/payment/view/payment_webview.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/features/store/model/store_response_model.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with SingleTickerProviderStateMixin {
  // State for selected delivery option
  QuoteResponseModel? _selectedQuote;
  String _selectedPaymentMethod = 'Paystack';

  /// The market the selected quote belongs to. Governs which payment sources
  /// are on offer and whether there is a wallet at all.
  Country _market = Country.ng;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showLocationSelectionOptions() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            const LocationSearchScreen(isPickupLocation: false),
      ),
    );

    if (result != null && result is LocationModel) {
      ref.read(cartProvider.notifier).setDropOffLocation(result);
      // Reset selected quote when location changes
      setState(() {
        _selectedQuote = null;
      });
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      AppStatusDialogs.showError(context, 'Error', message);
    }
  }

  Future<void> _handleProceedToPayment() async {
    ref.read(appLoggerProvider);
    final cartState = ref.read(cartProvider);
    final cartProducts = cartState.products;
    final dropOffLocation = cartState.dropOffLocation;
    final currentUser = ref.read(userProvider);
    final initialPersonalInfo = ref.read(personalInfoViewModelProvider);

    if (!GuestModeUtils.requireAuthForBuying(context)) return;
    if (cartProducts.isEmpty) {
      _showSnackbar('Your cart is empty.');
      return;
    }
    if (dropOffLocation == null) {
      _showSnackbar('Please add a drop-off location.');
      return;
    }
    if (currentUser == null) {
      _showSnackbar('User information is missing. Please log in again.');
      return;
    }

    // Ensure a quote is selected
    if (_selectedQuote == null) {
      _showSnackbar('Please select a delivery option.');
      return;
    }

    // Validate selected quote (re-verify if needed or just trust state)
    if (!_selectedQuote!.isAvailable) {
      _showSnackbar('Selected delivery option is unavailable.');
      return;
    }

    // Quotes are single-use and expire 15 minutes after the server issues them.
    if (_selectedQuote!.isExpired) {
      setState(() => _selectedQuote = null);
      ref.invalidate(deliveryFeeProvider);
      _showSnackbar(
          'That price expired. We have re-priced your delivery — please confirm again.');
      return;
    }

    final double deliveryFee = _selectedQuote!.price;
    final int? externalDeliveryFeeId = _selectedQuote!.externalDeliveryFeeId;
    final String deliveryType = _selectedQuote!.deliveryType;
    final String deliveryProvider =
        externalDeliveryFeeId != null ? 'Chowdeck' : 'Internal';

    final String? storeId =
        cartProducts.isNotEmpty ? cartProducts.first.store : '';
    if (storeId == null || storeId.isEmpty) {
      _showSnackbar('Unable to determine store for the order.');
      return;
    }

    double subtotal = cartProducts.fold(
        0.0, (sum, item) => sum + (item.price * (item.quantity ?? 0)));

    final productPayloads = cartProducts.map((item) {
      return ProductOrderPayload(
        product: item.id,
        quantity: item.quantity ?? 1,
      );
    }).toList();

    final now = DateTime.now();
    final String formattedDate = DateFormat('MMMM dd, yyyy').format(now);
    final String formattedTime = DateFormat('h:mm a').format(now);

    final orderPayload = CreateStoreOrderPayload(
      state: initialPersonalInfo.address,
      store: storeId,
      products: productPayloads,
      amount: subtotal,
      deliveryFee: deliveryFee,
      dropoffLocation: dropOffLocation.formattedAddress!,
      deliveryType: deliveryType,
      orderType: 'Shopping',
      date: formattedDate,
      time: formattedTime,
      note: 'Order from App',
      description: '',
      paymentSource: _market.paymentSourceOrNull(_selectedPaymentMethod),
      deliveryProvider: deliveryProvider,
      externalDeliveryFeeId: externalDeliveryFeeId,
      // Prices the order server-side. Null on Chowdeck quotes, which fall
      // back to sending the fee.
      quoteId: _selectedQuote!.quoteId,
    );

    ref.read(appLoggerProvider).d('Payload to send: ${orderPayload.toJson()}');

    final orderResponse = await ref
        .read(storeOrderViewModelProvider.notifier)
        .createOrder(orderPayload);

    if (orderResponse != null) {
      if (mounted) {
        if (orderResponse.authorizationUrl != null &&
            orderResponse.authorizationUrl!.isNotEmpty) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => PaymentWebViewScreen(
                    paymentUrl: orderResponse.authorizationUrl!,
                    orderId: orderResponse.order?.id ?? '',
                    reference: orderResponse.reference ?? '',
                    isStoreOrder: true,
                  )));
        } else {
          NavigationService.instance.navigateToReplaceAll(
            NavigatorRoutes.paymentVerificationScreen,
            argument: {
              'orderId': orderResponse.order?.id ?? '',
              'reference': orderResponse.reference ?? '',
              'isStoreOrder': true,
            },
          );
        }
      }
    } else {
      final errorMessage = ref.read(storeOrderViewModelProvider).error;
      if (errorMessage != null) {
        if (isStaleQuoteMessage(errorMessage)) {
          setState(() => _selectedQuote = null);
          ref.invalidate(deliveryFeeProvider);
          _showSnackbar(
              'That price expired. We have re-priced your delivery — please confirm again.');
        } else {
          _showSnackbar('Failed to create order: $errorMessage');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    ref.watch(appLoggerProvider); // Maintain logging
    final storeOrderState = ref.watch(storeOrderViewModelProvider);
    final walletState = ref.watch(walletOverviewViewModelProvider);

    final cartItems = cartState.products;
    final dropOffLocation = cartState.dropOffLocation;

    final deliveryFeeParams = DeliveryFeeParams(
      dropOffLocation: dropOffLocation,
      products: cartItems,
      deliveryType:
          'express', // This param might be redundant now as we fetch all
    );

    final AsyncValue<List<QuoteResponseModel>> deliveryQuotesAsync = ref.watch(
      deliveryFeeProvider(deliveryFeeParams),
    );

    double subtotal = cartItems.fold(
        0.0, (sum, item) => sum + (item.price * (item.quantity ?? 0)));

    // Render every amount in the quote's own currency, and charge what the
    // server says to charge: the delivery's grandTotal already carries its
    // processing fee and tax.
    final Currency currency = _selectedQuote?.currency ?? Currency.ngn;
    _market = _selectedQuote?.country ?? Country.ng;
    // A selection carried over from another market would be rejected.
    if (!_market.paymentSources.contains(_selectedPaymentMethod)) {
      _selectedPaymentMethod = _market.paymentSources.first;
    }
    final double deliveryFee = _selectedQuote?.fare.amount ?? 0.0;
    final double deliveryDue = _selectedQuote?.amountDue.amount ?? 0.0;
    final double total = subtotal + deliveryDue;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Shopping Cart',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text('Clear Cart'),
                    content: const Text(
                        'Are you sure you want to remove all items?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clearCart();
                          Navigator.pop(context);
                        },
                        child: Text('Clear',
                            style: TextStyle(color: Colors.red[400])),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 100, color: Colors.grey[300]),
                  Gap.h16,
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  Gap.h8,
                  Text(
                    'Add items to get started',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Gap.h10,
                    // Cart Items
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CartItemCard(
                              product: item,
                              onQuantityChanged: (newQty) {
                                if (newQty > (item.quantity ?? 0)) {
                                  ref
                                      .read(cartProvider.notifier)
                                      .addProduct(item);
                                } else {
                                  ref
                                      .read(cartProvider.notifier)
                                      .removeProduct(item);
                                }
                              },
                              onRemoveCompletely: (itemToRemove) {
                                ref
                                    .read(cartProvider.notifier)
                                    .removeProductCompletely(itemToRemove);
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Section with Location, Payment, and Summary
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Delivery Location Card
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                            child: InkWell(
                              onTap: _showLocationSelectionOptions,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: dropOffLocation == null
                                      ? LinearGradient(
                                          colors: [
                                            AppColors.primary.withOpacity(0.1),
                                            AppColors.primary.withOpacity(0.05),
                                          ],
                                        )
                                      : null,
                                  color: dropOffLocation == null
                                      ? null
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: dropOffLocation == null
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                    width: dropOffLocation == null ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: dropOffLocation == null
                                            ? AppColors.primary
                                            : Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        dropOffLocation == null
                                            ? Icons.add_location_alt_outlined
                                            : Icons.location_on,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    Gap.w12,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dropOffLocation == null
                                                ? 'Add Delivery Location'
                                                : 'Delivering to',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          if (dropOffLocation != null) ...[
                                            Gap.h4,
                                            Text(
                                              dropOffLocation
                                                      .formattedAddress ??
                                                  '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      dropOffLocation == null
                                          ? Icons.add
                                          : Icons.edit_outlined,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Delivery Options Selector
                          if (dropOffLocation != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Delivery Options',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Gap.h12,
                                  SizedBox(
                                    height: 90,
                                    child: deliveryQuotesAsync.when(
                                      data: (quotes) {
                                        if (quotes.isEmpty) {
                                          return const Text(
                                              'No delivery options available');
                                        }

                                        // Auto-select first available if none selected
                                        if (_selectedQuote == null &&
                                            quotes.any((q) => q.isAvailable)) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            if (mounted) {
                                              setState(() {
                                                _selectedQuote =
                                                    quotes.firstWhere(
                                                        (q) => q.isAvailable);
                                              });
                                            }
                                          });
                                        }

                                        return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: quotes.length,
                                          itemBuilder: (context, index) {
                                            final quote = quotes[index];
                                            // Map deliveryType to display title
                                            String displayTitle = "Standard";
                                            if (quote.deliveryType
                                                    .toLowerCase() ==
                                                'express') {
                                              displayTitle = "Express";
                                            }
                                            if (quote.deliveryType
                                                    .toLowerCase() ==
                                                'priority') {
                                              displayTitle = "Priority+";
                                            }

                                            return _DeliveryOptionCard(
                                              title: displayTitle,
                                              price: quote.amountDue.format(),
                                              isSelected:
                                                  _selectedQuote == quote,
                                              isAvailable: quote.isAvailable,
                                              onTap: () {
                                                setState(() {
                                                  _selectedQuote = quote;
                                                });
                                              },
                                            );
                                          },
                                        );
                                      },
                                      loading: () => const Center(
                                          child: CircularProgressIndicator()),
                                      error: (e, s) => Text(
                                          'Error loading options: $e',
                                          style: const TextStyle(
                                              color: Colors.red)),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          Gap.h12,

                          // Payment Method Selection
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Method',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Gap.h12,
                                InkWell(
                                  onTap: () {
                                    final double? walletBalance =
                                        walletState.walletBalance.valueOrNull;
                                    final bool isWalletInsufficient =
                                        _market.hasCustomerWallet &&
                                            _selectedQuote != null &&
                                            walletBalance != null &&
                                            _selectedQuote!.amountDue.amount >
                                                walletBalance;

                                    _showPaymentMethodPicker(context,
                                        walletBalance, isWalletInsufficient);
                                  },
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8.w),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _selectedPaymentMethod == 'Wallet'
                                                ? Icons.account_balance_wallet
                                                : Icons.credit_card,
                                            color: AppColors.primary,
                                            size: 20.sp,
                                          ),
                                        ),
                                        Gap.w12,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedPaymentMethod,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16.sp,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            if (_selectedPaymentMethod ==
                                                'Wallet')
                                              Text(
                                                'Balance: ${(walletState.walletBalance.valueOrNull ?? 0).toMoney()}',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Icon(Icons.keyboard_arrow_down,
                                            color: Colors.grey.shade600),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Gap.h20,

                          // Order Summary
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow(
                                    'Subtotal', subtotal.toMoney(currency)),
                                Gap.h12,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Delivery Fee',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      deliveryFee.toMoney(currency),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                // Itemised by the server. Zero and therefore
                                // absent on Nigerian plain deliveries.
                                if ((_selectedQuote?.serviceFee ?? 0) > 0) ...[
                                  Gap.h12,
                                  _buildSummaryRow(
                                    'Processing fee',
                                    _selectedQuote!.serviceFee!
                                        .toMoney(currency),
                                  ),
                                ],
                                if ((_selectedQuote?.taxAmount ?? 0) > 0) ...[
                                  Gap.h12,
                                  _buildSummaryRow(
                                    _selectedQuote!.taxLabel?.isNotEmpty == true
                                        ? _selectedQuote!.taxLabel!
                                        : 'Tax',
                                    _selectedQuote!.taxAmount!
                                        .toMoney(currency),
                                  ),
                                ],
                                Gap.h12,
                                Divider(color: Colors.grey[300], thickness: 1),
                                Gap.h12,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      total.toMoney(currency),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Gap.h20,

                          // Checkout Button
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: (storeOrderState.isLoading ||
                                        dropOffLocation == null ||
                                        _selectedQuote == null)
                                    ? null
                                    : _handleProceedToPayment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  disabledBackgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: storeOrderState.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Proceed to Checkout',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showPaymentMethodPicker(
      BuildContext context, double? walletBalance, bool isWalletInsufficient) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Gap.h24,
              for (final source in _market.paymentSources) ...[
                _buildPaymentDetailOption(
                  context,
                  source,
                  source == 'Wallet'
                      ? Icons.account_balance_wallet
                      : Icons.credit_card,
                  source == 'Wallet' && isWalletInsufficient,
                  source == 'Wallet'
                      ? (isWalletInsufficient
                          ? 'Insufficient funds'
                          : 'Balance: ${(walletBalance ?? 0).toMoney()}')
                      : 'Pay securely with card',
                ),
                Gap.h16,
              ],
              // Gap.h16,
              // _buildPaymentDetailOption(
              //   context,
              //   'Globus Bank',
              //   Icons.account_balance,
              //   false,
              //   'Pay with Globus Bank',
              // ),
              Gap.h32,
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentDetailOption(BuildContext context, String title,
      IconData icon, bool isDisabled, String subtitle) {
    final bool isSelected = _selectedPaymentMethod == title;
    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                if (title == 'Globus Bank') {
                  _selectedPaymentMethod = 'Globus';
                } else {
                  _selectedPaymentMethod = title;
                }
              });
              Navigator.pop(context);
            },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey.shade50
              : (isSelected
                  ? AppColors.primary.withOpacity(0.05)
                  : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDisabled
                ? Colors.grey.shade200
                : (isSelected ? AppColors.primary : Colors.grey.shade200),
            width: 1.5.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey.shade200
                    : (isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24.sp,
                color: isDisabled
                    ? Colors.grey.shade400
                    : (isSelected ? AppColors.primary : Colors.grey.shade600),
              ),
            ),
            Gap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? Colors.grey.shade400 : Colors.black87,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDisabled
                          ? Colors.red.shade300
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24.sp,
              )
            else
              Icon(
                Icons.radio_button_off,
                color: Colors.grey.shade300,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }
}

// Provider classes remain the same
class DeliveryFeeParams extends Equatable {
  final LocationModel? dropOffLocation;
  final List<StoreProduct> products;
  final String deliveryType;

  const DeliveryFeeParams({
    required this.dropOffLocation,
    required this.products,
    required this.deliveryType,
  });

  @override
  List<Object?> get props => [dropOffLocation, products, deliveryType];
}

final deliveryFeeProvider =
    FutureProvider.family<List<QuoteResponseModel>, DeliveryFeeParams>(
  (ref, params) async {
    final appLogger = ref.read(appLoggerProvider);
    appLogger.d('>>> DELIVERY FEE PROVIDER FUNCTION STARTED <<<');

    final dropOffLocation = params.dropOffLocation;
    final cartProducts = params.products;

    if (dropOffLocation == null) {
      appLogger.d(
          'DeliveryFeeProvider: dropOffLocation is null. Returning empty list.');
      return [];
    }
    if (cartProducts.isEmpty) {
      appLogger.w('DeliveryFeeProvider: cartProducts is empty.');
      return [];
    }

    final storeId = cartProducts.first.store;
    if (storeId == null || storeId.isEmpty) {
      appLogger.e('DeliveryFeeProvider: Store ID is null or empty.');
      throw Exception('Store ID not found');
    }

    final storeService = ref.read(storeServiceProvider);

    try {
      appLogger.d(
          '  Calling storeService.fetchDeliveryQuote (Express + Priority)...');
      final quotes = await storeService.fetchDeliveryQuote(
        storeId: storeId,
        dropoffLocation: dropOffLocation,
      );
      appLogger.d('  Fetched ${quotes.length} delivery quotes.');
      appLogger.d('<<< DELIVERY FEE PROVIDER FUNCTION ENDED (SUCCESS) >>>');
      return quotes;
    } catch (e, st) {
      appLogger.e('Failed to fetch delivery quotes: $e',
          error: e, stackTrace: st);
      appLogger.d('<<< DELIVERY FEE PROVIDER FUNCTION ENDED (ERROR) >>>');
      rethrow;
    }
  },
);

final storeDetailsProvider =
    FutureProvider.family<SingleStoreData, String>((ref, storeId) async {
  final storeService = ref.read(storeServiceProvider);
  return storeService.getSingleStore(storeId);
});

// New Widget for Delivery Option Card
// New Widget for Delivery Option Card
class _DeliveryOptionCard extends StatelessWidget {
  final String title;
  final String price;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;

  const _DeliveryOptionCard({
    required this.title,
    required this.price,
    required this.isSelected,
    this.isAvailable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine styles based on type (simulated by title checking or passed color)
    final bool isExpress = title.toLowerCase() == 'express';
    // Check if title contains priority or Priority+
    final bool isPriority = title.toLowerCase().contains('priority');

    Color backgroundColor = Colors.white;
    Color textColor = Colors.black87;

    if (isExpress) {
      // Express is Black
      backgroundColor = Colors.black;
      textColor = Colors.white;
    } else if (isPriority) {
      // Priority+ is Gradient (Purple/Green) - applied to container
      // Use a solid fallback if needed, but here we set textColor
      textColor = Colors.white;
    }

    // Override for selection border
    final borderColor = isSelected ? AppColors.primary : Colors.grey.shade300;

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.5,
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          width: 140,
          padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
          decoration: BoxDecoration(
            color: isPriority ? null : backgroundColor,
            gradient: isPriority
                ? const LinearGradient(
                    colors: [
                      Color(0xFF9C27B0),
                      Color(0xFF00C853)
                    ], // Purple to Green
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Positioned(
                left: 70.h,
                top: 20.h,
                right: 2,
                bottom: 2,
                child: Image.asset(ImageAsset.riderBikeImg),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title == 'Express' ? 'Regular' : title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isAvailable)
                    Text(
                      price,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    )
                  else
                    Text(
                      'Unavailable',
                      style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 12,
                          fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
