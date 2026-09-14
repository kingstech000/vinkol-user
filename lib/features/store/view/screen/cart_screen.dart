import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/booking/view/screen/location_search_screen.dart';
import 'package:starter_codes/features/payment/view/payment_webview.dart';
import 'package:starter_codes/features/profile/view_model/personal_info_view_model.dart';
import 'package:starter_codes/features/store/data/store_service.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/model/store_request_model.dart';
import 'package:starter_codes/features/store/model/store_response_model.dart';
import 'package:starter_codes/features/store/view/widget/cart_item_card.dart';
import 'package:starter_codes/features/store/view/widget/checkout_widgets.dart';
import 'package:starter_codes/features/store/view/widget/store_ui.dart';
import 'package:starter_codes/features/store/view_model/order_view_model.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/provider/market_provider.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';

/// The basket and the checkout, on one scrolling page: what is in it, where
/// it is going, how it gets there, how it is paid for, and what it comes to.
/// The pay button is pinned underneath, and when it cannot be pressed the
/// bar says which step is missing rather than going quiet.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  QuoteResponseModel? _selectedQuote;
  String _selectedPaymentMethod = 'Paystack';

  /// The market the selected quote belongs to. Governs which payment sources
  /// are on offer and whether there is a wallet at all.
  Country _market = Country.ng;

  Future<void> _pickAddress() async {
    final result = await Navigator.of(context).push<LocationModel?>(
      MaterialPageRoute(
        builder: (_) => const LocationSearchScreen(isPickupLocation: false),
      ),
    );
    if (result != null) {
      ref.read(cartProvider.notifier).setDropOffLocation(result);
      // A new address means new prices.
      setState(() => _selectedQuote = null);
    }
  }

  void _showError(String message) {
    if (mounted) AppStatusDialogs.showError(context, 'Error', message);
  }

  void _confirmClear() {
    AppStatusDialogs.showConfirmation(
      context,
      title: 'Empty your cart?',
      message: 'Everything in it will be removed.',
      confirmText: 'Empty cart',
      cancelText: 'Keep',
      onConfirm: () => ref.read(cartProvider.notifier).clearCart(),
    );
  }

  Future<void> _changePaymentMethod(Money? walletBalance) async {
    final insufficient = _market.hasCustomerWallet &&
        _selectedQuote != null &&
        walletBalance != null &&
        _selectedQuote!.amountDue.amount > walletBalance.amount;
    final picked = await showPaymentSourceSheet(
      context,
      sources: _market.paymentSources,
      selected: _selectedPaymentMethod,
      walletBalance: walletBalance,
      walletInsufficient: insufficient,
    );
    if (picked != null && mounted) {
      setState(() => _selectedPaymentMethod = picked);
    }
  }

  Future<void> _handleProceedToPayment() async {
    final cartState = ref.read(cartProvider);
    final cartProducts = cartState.products;
    final dropOffLocation = cartState.dropOffLocation;
    final currentUser = ref.read(userProvider);
    final initialPersonalInfo = ref.read(personalInfoViewModelProvider);

    if (!GuestModeUtils.requireAuthForBuying(context)) return;

    if (cartProducts.isEmpty) {
      _showError('Your cart is empty.');
      return;
    }
    if (dropOffLocation == null) {
      _showError('Add a delivery address first.');
      return;
    }
    if (currentUser == null) {
      _showError('User information is missing. Please log in again.');
      return;
    }
    if (_selectedQuote == null) {
      _showError('Choose a delivery option.');
      return;
    }
    if (!_selectedQuote!.isAvailable) {
      _showError('That delivery option is unavailable.');
      return;
    }
    // Quotes are single-use and expire 15 minutes after the server issues them.
    if (_selectedQuote!.isExpired) {
      setState(() => _selectedQuote = null);
      ref.invalidate(deliveryFeeProvider);
      _showError(
          'That price expired. We have re-priced your delivery — please confirm again.');
      return;
    }

    final double deliveryFee = _selectedQuote!.price;
    final int? externalDeliveryFeeId = _selectedQuote!.externalDeliveryFeeId;
    final String deliveryType = _selectedQuote!.deliveryType;
    final String deliveryProvider =
        externalDeliveryFeeId != null ? 'Chowdeck' : 'Internal';

    final String? storeId = cartProducts.first.store;
    if (storeId == null || storeId.isEmpty) {
      _showError('Unable to determine store for the order.');
      return;
    }

    final double subtotal = cartProducts.fold(
        0.0, (sum, item) => sum + (item.price * (item.quantity ?? 0)));

    final productPayloads = cartProducts
        .map((item) => ProductOrderPayload(
              product: item.id,
              quantity: item.quantity ?? 1,
            ))
        .toList();

    final now = DateTime.now();
    final orderPayload = CreateStoreOrderPayload(
      state: initialPersonalInfo.address,
      store: storeId,
      products: productPayloads,
      amount: subtotal,
      deliveryFee: deliveryFee,
      dropoffLocation: dropOffLocation.formattedAddress!,
      deliveryType: deliveryType,
      orderType: 'Shopping',
      date: DateFormat('MMMM dd, yyyy').format(now),
      time: DateFormat('h:mm a').format(now),
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

    if (!mounted) return;

    if (orderResponse != null) {
      final url = orderResponse.authorizationUrl;
      if (url != null && url.isNotEmpty) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            paymentUrl: url,
            orderId: orderResponse.order?.id ?? '',
            reference: orderResponse.reference ?? '',
            isStoreOrder: true,
          ),
        ));
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
      return;
    }

    final errorMessage = ref.read(storeOrderViewModelProvider).error;
    if (errorMessage == null) return;
    if (isStaleQuoteMessage(errorMessage)) {
      setState(() => _selectedQuote = null);
      ref.invalidate(deliveryFeeProvider);
      _showError(
          'That price expired. We have re-priced your delivery — please confirm again.');
    } else {
      _showError('Failed to create order: $errorMessage');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final storeOrderState = ref.watch(storeOrderViewModelProvider);
    final walletState = ref.watch(walletOverviewViewModelProvider);
    final store = ref.watch(currentStoreProvider);

    final items = cartState.products;
    final dropOffLocation = cartState.dropOffLocation;

    final quotes = ref.watch(deliveryFeeProvider(DeliveryFeeParams(
      dropOffLocation: dropOffLocation,
      products: items,
      deliveryType: 'express',
    )));

    // Every amount renders in the quote's currency once there is one, and in
    // the products' own currency before that — the cart is single-store, so
    // the lines all agree.
    final Currency currency = _selectedQuote?.currency ??
        (items.isEmpty ? Currency.ngn : items.first.currency);
    _market = _selectedQuote?.country ??
        (items.isEmpty ? Country.ng : items.first.country);
    // A selection carried over from another market would be rejected.
    if (!_market.paymentSources.contains(_selectedPaymentMethod)) {
      _selectedPaymentMethod = _market.paymentSources.first;
    }

    final subtotal = Money(
      items.fold<double>(0, (sum, p) => sum + p.price * (p.quantity ?? 0)),
      currency,
    );
    final delivery = _selectedQuote?.fare;
    final due = _selectedQuote?.amountDue.amount ?? 0;
    final total = Money(subtotal.amount + due, currency);

    final walletBalance = walletState.walletBalance.valueOrNull;
    final walletMoney =
        walletBalance == null ? null : Money(walletBalance, currency);

    final String? blocker = items.isEmpty
        ? 'Your cart is empty'
        : dropOffLocation == null
            ? 'Add a delivery address to continue'
            : _selectedQuote == null
                ? 'Choose a delivery option to continue'
                : null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MiniAppBar(
        title: 'Cart',
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: _confirmClear,
              child: AppText.button(
                'Clear',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: VinkolPalette.neutral600,
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? StoreStateView(
              icon: PhosphorIconsRegular.basket,
              title: 'Your cart is empty',
              message: 'Anything you add from a store will show up here.',
              actionLabel: 'Browse stores',
              onAction: () => Navigator.of(context).maybePop(),
            )
          : SafeArea(
              top: false,
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  VinkolSpace.pageMargin,
                  VinkolSpace.xs,
                  VinkolSpace.pageMargin,
                  VinkolSpace.xxxl,
                ),
                children: [
                  _BasketHeader(storeName: store?.name, items: items),
                  Gap.h8,
                  _Card(
                    child: Column(
                      children: [
                        for (final item in items) ...[
                          CartItemCard(
                            product: item,
                            onIncrement: () => ref
                                .read(cartProvider.notifier)
                                .addProduct(item),
                            onDecrement: () => ref
                                .read(cartProvider.notifier)
                                .removeProduct(item),
                          ),
                          if (item != items.last)
                            const Divider(
                                height: 1, color: VinkolPalette.neutral100),
                        ],
                      ],
                    ),
                  ),
                  const Gap.h(VinkolSpace.sectionGap),
                  const CheckoutSectionLabel('Deliver to'),
                  Gap.h10,
                  DeliveryAddressRow(
                    address: dropOffLocation?.formattedAddress,
                    onTap: _pickAddress,
                  ),
                  if (dropOffLocation != null) ...[
                    const Gap.h(VinkolSpace.sectionGap),
                    const CheckoutSectionLabel('Delivery'),
                    Gap.h10,
                    _DeliveryOptions(
                      quotes: quotes,
                      selected: _selectedQuote,
                      onSelect: (q) => setState(() => _selectedQuote = q),
                      onRetry: () => ref.invalidate(deliveryFeeProvider),
                    ),
                  ],
                  const Gap.h(VinkolSpace.sectionGap),
                  const CheckoutSectionLabel('Payment'),
                  Gap.h10,
                  PaymentMethodRow(
                    method: _selectedPaymentMethod,
                    detail: _selectedPaymentMethod == 'Wallet' &&
                            walletMoney != null
                        ? 'Balance ${walletMoney.format()}'
                        : null,
                    onTap: _market.offersPaymentChoice
                        ? () => _changePaymentMethod(walletMoney)
                        : null,
                  ),
                  const Gap.h(VinkolSpace.sectionGap),
                  const CheckoutSectionLabel('Summary'),
                  Gap.h12,
                  _Card(
                    padded: true,
                    child: OrderSummary(
                      subtotal: subtotal,
                      delivery: delivery,
                      deliveryPlaceholder: dropOffLocation == null
                          ? 'Add an address'
                          : 'Choose an option',
                      serviceFee: _selectedQuote?.serviceFeeMoney,
                      tax: _selectedQuote?.taxMoney,
                      taxLabel: _selectedQuote?.taxLabel,
                      total: total,
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : _PayBar(
              total: total,
              blocker: blocker,
              loading: storeOrderState.isLoading,
              onPay: _handleProceedToPayment,
            ),
    );
  }
}

/// A white surface on the canvas, holding rows that are not cards themselves.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padded = false});

  final Widget child;

  /// Full card padding, for content that has no row padding of its own.
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: VinkolSpace.lg,
        vertical: padded ? VinkolSpace.lg : VinkolSpace.xs,
      ),
      decoration: const BoxDecoration(
        color: VinkolPalette.white,
        borderRadius: VinkolRadius.brMd,
      ),
      child: child,
    );
  }
}

/// "From Cole World Stores · 3 items" — the basket is single-store, so the
/// store is named once at the top rather than on every row.
class _BasketHeader extends StatelessWidget {
  const _BasketHeader({required this.storeName, required this.items});

  final String? storeName;
  final List<StoreProduct> items;

  @override
  Widget build(BuildContext context) {
    final count = items.fold<int>(0, (sum, p) => sum + (p.quantity ?? 0));
    final name = storeName?.trim();
    final parts = [
      if (name != null && name.isNotEmpty) 'From $name',
      count == 1 ? '1 item' : '$count items',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: VinkolSpace.xs),
      child: AppText.caption(
        parts.join(' · '),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: VinkolPalette.neutral500,
        maxLines: 1,
      ),
    );
  }
}

/// The priced options, or why there are none yet.
class _DeliveryOptions extends StatelessWidget {
  const _DeliveryOptions({
    required this.quotes,
    required this.selected,
    required this.onSelect,
    required this.onRetry,
  });

  final AsyncValue<List<QuoteResponseModel>> quotes;
  final QuoteResponseModel? selected;
  final ValueChanged<QuoteResponseModel> onSelect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return quotes.when(
      loading: () => const DeliveryOptionsSkeleton(),
      error: (_, __) => _InlineNotice(
        icon: PhosphorIconsRegular.warningCircle,
        text: 'We couldn’t price this delivery.',
        actionLabel: 'Try again',
        onAction: onRetry,
      ),
      data: (list) {
        if (list.isEmpty) {
          return const _InlineNotice(
            icon: PhosphorIconsRegular.prohibit,
            text: 'No delivery options reach this address yet.',
          );
        }
        // Pre-select the first usable option so the customer only has to act
        // if they want something else.
        if (selected == null && list.any((q) => q.isAvailable)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onSelect(list.firstWhere((q) => q.isAvailable));
          });
        }
        return Column(
          children: [
            for (final quote in list) ...[
              DeliveryOptionTile(
                quote: quote,
                selected: selected == quote,
                onTap: () => onSelect(quote),
              ),
              if (quote != list.last) Gap.h10,
            ],
          ],
        );
      },
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(VinkolSpace.lg),
      decoration: BoxDecoration(
        borderRadius: VinkolRadius.brMd,
        border: Border.all(color: VinkolPalette.neutral200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: VinkolPalette.neutral500),
          Gap.w12,
          Expanded(
            child: AppText.body(
              text,
              fontSize: 14,
              color: VinkolPalette.neutral700,
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: AppText.button(
                actionLabel!,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: VinkolPalette.brand600,
              ),
            ),
        ],
      ),
    );
  }
}

/// The pinned pay button. Blocked, it keeps its shape and says what is
/// missing above it; nothing on this screen is ever disabled in silence.
class _PayBar extends StatelessWidget {
  const _PayBar({
    required this.total,
    required this.blocker,
    required this.loading,
    required this.onPay,
  });

  final Money total;
  final String? blocker;
  final bool loading;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final blocked = blocker != null;
    return Container(
      decoration: const BoxDecoration(
        color: VinkolPalette.white,
        border: Border(top: BorderSide(color: VinkolPalette.neutral100)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            VinkolSpace.pageMargin,
            VinkolSpace.md,
            VinkolSpace.pageMargin,
            VinkolSpace.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (blocked) ...[
                Row(
                  children: [
                    const Icon(
                      PhosphorIconsRegular.info,
                      size: 16,
                      color: VinkolPalette.neutral500,
                    ),
                    Gap.w6,
                    Expanded(
                      child: AppText.caption(
                        blocker!,
                        fontSize: 13,
                        color: VinkolPalette.neutral600,
                      ),
                    ),
                  ],
                ),
                Gap.h10,
              ],
              AppButton.primary(
                title: blocked ? 'Pay' : 'Pay ${total.format()}',
                disable: blocked,
                loading: loading,
                onTap: onPay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

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
    final dropOffLocation = params.dropOffLocation;
    final cartProducts = params.products;

    if (dropOffLocation == null) {
      appLogger.d('DeliveryFeeProvider: no drop-off yet, nothing to price.');
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
      final quotes = await storeService.fetchDeliveryQuote(
        storeId: storeId,
        country: ref.read(marketProvider),
        dropoffLocation: dropOffLocation,
      );
      appLogger.d('DeliveryFeeProvider: ${quotes.length} quotes.');
      return quotes;
    } catch (e, st) {
      appLogger.e('Failed to fetch delivery quotes: $e',
          error: e, stackTrace: st);
      rethrow;
    }
  },
);

final storeDetailsProvider =
    FutureProvider.family<SingleStoreData, String>((ref, storeId) async {
  final storeService = ref.read(storeServiceProvider);
  return storeService.getSingleStore(
    storeId,
    country: ref.read(marketProvider),
  );
});
