import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/core/market/models.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/booking/view/screen/location_search_screen.dart';
import 'package:starter_codes/features/booking/view/widget/quote/order_checkout.dart';
import 'package:starter_codes/features/booking/view/widget/quote/payment_source_selector.dart';
import 'package:starter_codes/features/booking/view/widget/quote/quote_summary.dart';
import 'package:starter_codes/features/profile/view_model/personal_info_view_model.dart';
import 'package:starter_codes/features/store/data/cart_providers.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/model/store_request_model.dart';
import 'package:starter_codes/features/store/model/store_response_model.dart';
import 'package:starter_codes/features/store/view/widget/cart_widgets.dart';
import 'package:starter_codes/features/store/view_model/order_view_model.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// The cart and checkout for a shopping order — `orderType: "Shopping"`.
///
/// Three things make this screen different from booking a delivery, and all three are stated
/// on it rather than left to be discovered:
///
///  * **One store per cart.** It is the rule users hit hardest, so it leads the screen rather
///    than appearing as an error after they have added something from a second shop.
///  * **The delivery fee is quoted, not calculated.** It comes back from
///    `orders/shopping-delivery-fee` as a list of options — a Vinkol rider, and a partner
///    courier where one covers the route — so it cannot be shown until there is an address.
///  * **The pickup is the store's address**, never one the user picks. There is no pickup
///    field on this screen for that reason.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  QuoteResponseModel? _selectedQuote;
  MarketPaymentProvider? _chosenPaymentSource;

  Future<void> _changeAddress() async {
    final Object? result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(
        builder: (BuildContext context) =>
            const LocationSearchScreen(isPickupLocation: false),
      ),
    );

    if (result is LocationModel) {
      ref.read(cartProvider.notifier).setDropOffLocation(result);
      // The quote was priced to the old address and is now meaningless.
      setState(() => _selectedQuote = null);
    }
  }

  Future<void> _placeOrder({
    required List<StoreProduct> products,
    required LocationModel dropOff,
    required QuoteResponseModel quote,
    required MarketPaymentProvider paymentSource,
    required double subtotal,
  }) async {
    if (!GuestModeUtils.requireAuthForBuying(context)) return;

    final String? storeId = products.first.store;
    if (storeId == null || storeId.isEmpty) {
      AppStatusDialogs.showError(context, context.l10n.bookingCouldNotBookTitle,
          context.l10n.storeCannotDetermineStore);
      return;
    }

    final DateTime now = DateTime.now();
    // A quote carrying an external id was priced by a partner courier; one without it is
    // carried by a Vinkol rider. The backend keys fulfilment off this pair.
    final int? externalDeliveryFeeId = quote.id;

    final CreateStoreOrderPayload payload = CreateStoreOrderPayload(
      state: ref.read(personalInfoViewModelProvider).address,
      store: storeId,
      products: products
          .map((StoreProduct item) => ProductOrderPayload(
                product: item.id,
                quantity: item.quantity ?? 1,
              ))
          .toList(),
      amount: subtotal.toInt(),
      deliveryFee: quote.price.toInt(),
      dropoffLocation: dropOff.formattedAddress ?? '',
      deliveryType: quote.deliveryType,
      orderType: 'Shopping',
      date: DateFormat('MMMM dd, yyyy').format(now),
      time: DateFormat('h:mm a').format(now),
      note: 'Order from App',
      description: '',
      paymentSource: paymentSource.id,
      deliveryProvider: externalDeliveryFeeId != null ? 'Chowdeck' : 'Internal',
      externalDeliveryFeeId: externalDeliveryFeeId,
    );

    final orderResponse = await ref
        .read(storeOrderViewModelProvider.notifier)
        .createOrder(payload);

    if (!mounted) return;

    if (orderResponse == null) {
      showBookingError(
        context,
        ref.read(storeOrderViewModelProvider).error ??
            context.l10n.storeCouldNotPlaceOrder,
      );
      return;
    }

    await routeAfterOrder(context, ref, orderResponse, isStoreOrder: true);
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final CartState cartState = ref.watch(cartProvider);
    final List<StoreProduct> items = cartState.products;

    if (items.isEmpty) {
      return _EmptyCart(
        canvas: v.canvas,
        onBrowse: () {
          // Shop is a dashboard tab rather than a route, so the way back to browsing is a
          // tab change, not a push.
          ref.read(navigationIndexProvider.notifier).state = 1;
          NavigationService.instance
              .navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
        },
      );
    }

    final LocationModel? dropOff = cartState.dropOffLocation;
    final double subtotal = items.fold<double>(
        0, (double sum, StoreProduct i) => sum + i.price * (i.quantity ?? 0));

    final AsyncValue<List<QuoteResponseModel>> quotes = ref.watch(
      deliveryFeeProvider(
        DeliveryFeeParams(dropOffLocation: dropOff, products: items),
      ),
    );

    // Pre-selected, not auto-assigned: the cheapest way to show a total is to default to the
    // first option the server can actually serve, and deriving it here avoids writing state
    // back from a post-frame callback the way this screen used to.
    final QuoteResponseModel? quote = _selectedQuote ??
        quotes.valueOrNull
            ?.where((QuoteResponseModel q) => q.isAvailable)
            .firstOrNull;
    final double deliveryFee = quote?.price ?? 0;
    final double goods = subtotal + deliveryFee;
    final double? walletBalance =
        ref.watch(walletOverviewViewModelProvider).walletBalance.valueOrNull;
    final MarketPaymentProvider paymentSource = resolvePaymentSource(
      chosen: _chosenPaymentSource,
      walletBalance: walletBalance,
      amount: goods + (MarketFormat.tax(goods)?.amount.toDouble() ?? 0),
    );
    final bool placing = ref.watch(storeOrderViewModelProvider).isLoading;

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: AppBar(
        backgroundColor: v.canvas,
        surfaceTintColor: v.canvas,
        elevation: 0,
        title: Text(l10n.storeShoppingCart,
            style: VinkolType.h3.copyWith(color: v.textPrimary)),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.storeClearCart,
            onPressed: () => _confirmClear(context),
            icon: Icon(Icons.delete_outline, color: v.textSecondary),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  VinkolSpace.pageMargin,
                  VinkolSpace.sm,
                  VinkolSpace.pageMargin,
                  VinkolSpace.xxl,
                ),
                children: <Widget>[
                  _OneStorePerCartNotice(storeId: items.first.store),
                  VinkolSectionHeader(
                    label: l10n.storeItems,
                    meta: '${items.length}',
                  ),
                  for (final StoreProduct item in items)
                    CartItemRow(
                      item: item,
                      onIncrement: () =>
                          ref.read(cartProvider.notifier).addProduct(item),
                      onDecrement: () =>
                          ref.read(cartProvider.notifier).removeProduct(item),
                    ),
                  VinkolSectionHeader(
                    label: l10n.storeDeliveringTo,
                    action: (
                      label:
                          dropOff == null ? l10n.bookingAdd : l10n.storeChange,
                      onTap: _changeAddress,
                    ),
                  ),
                  VinkolRowGroup(
                    children: <VinkolRow>[
                      VinkolRow(
                        title: dropOff?.formattedAddress ??
                            l10n.storeAddDeliveryAddress,
                        meta: dropOff == null
                            ? l10n.storeNeededToQuoteDelivery
                            : l10n.storeSetOnThisOrder,
                        icon: Icons.location_on_outlined,
                        accentIcon: dropOff != null,
                        titleMaxLines: 2,
                        onTap: _changeAddress,
                      ),
                    ],
                  ),
                  VinkolSectionHeader(label: l10n.storeDeliveryOptions),
                  DeliveryOptionList(
                    quotes: quotes,
                    selected: quote,
                    hasAddress: dropOff != null,
                    onSelected: (QuoteResponseModel quote) =>
                        setState(() => _selectedQuote = quote),
                    onAddAddress: _changeAddress,
                  ),
                  VinkolSectionHeader(label: l10n.storePayment),
                  QuoteMoneyCard(
                    subtotal: goods,
                    lines: <({String amount, String label})>[
                      (
                        label: l10n.storeSubtotal,
                        amount: MarketFormat.money(subtotal)
                      ),
                      (
                        label: l10n.storeDeliveryFee,
                        amount: quote == null
                            ? l10n.storeNotQuotedYet
                            : MarketFormat.money(deliveryFee)
                      ),
                    ],
                  ),
                  const SizedBox(height: VinkolSpace.md),
                  PaymentSourceField(
                    selected: paymentSource,
                    amount: goods,
                    walletBalance: walletBalance,
                    onChanged: (MarketPaymentProvider provider) =>
                        setState(() => _chosenPaymentSource = provider),
                  ),
                ],
              ),
            ),
            VinkolDock(
              label: l10n.storeTotal,
              value: MarketFormat.money(
                  goods + (MarketFormat.tax(goods)?.amount.toDouble() ?? 0)),
              detail: _blockingReason(l10n, dropOff, quote),
              actionLabel: l10n.storePlaceOrder,
              loading: placing,
              onAction: dropOff != null && quote != null
                  ? () => _placeOrder(
                        products: items,
                        dropOff: dropOff,
                        quote: quote,
                        paymentSource: paymentSource,
                        subtotal: subtotal,
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Why the order cannot be placed yet, in the user's terms. A disabled button that does not
  /// say what is missing is a dead end.
  String? _blockingReason(
    AppLocalizations l10n,
    LocationModel? dropOff,
    QuoteResponseModel? quote,
  ) {
    if (dropOff == null) return l10n.storeAddAnAddressToContinue;
    if (quote == null) return l10n.storeChooseADeliveryOption;
    return null;
  }

  Future<void> _confirmClear(BuildContext context) async {
    final l10n = context.l10n;
    final bool? clear = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: context.vinkol.surface,
        shape: const RoundedRectangleBorder(borderRadius: VinkolRadius.brLg),
        title: Text(l10n.storeClearCart,
            style: VinkolType.h3.copyWith(color: context.vinkol.textPrimary)),
        content: Text(l10n.storeAreYouSureYouWant,
            style:
                VinkolType.body.copyWith(color: context.vinkol.textSecondary)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.storeCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.storeClear,
                style: TextStyle(color: context.vinkol.danger)),
          ),
        ],
      ),
    );

    if (clear ?? false) ref.read(cartProvider.notifier).clearCart();
  }
}

/// The rule, named. StoreProduct carries a store id and no store name, so the name is read
/// from the store record — and until it arrives the rule is still stated, because the rule is
/// the point and the name is only the courtesy.
class _OneStorePerCartNotice extends ConsumerWidget {
  const _OneStorePerCartNotice({required this.storeId});

  final String? storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? id = storeId;
    final String name = id == null || id.isEmpty
        ? context.l10n.storeThisStore
        : ref.watch(storeDetailsProvider(id)).maybeWhen(
              data: (SingleStoreData data) =>
                  data.store.name ?? context.l10n.storeThisStore,
              orElse: () => context.l10n.storeThisStore,
            );

    return VinkolNotice(
      icon: Icons.storefront_outlined,
      headline: name,
      body: context.l10n.storeOneStorePerOrder,
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.canvas, required this.onBrowse});

  final Color canvas;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        surfaceTintColor: canvas,
        elevation: 0,
        title: Text(context.l10n.storeShoppingCart,
            style: VinkolType.h3.copyWith(color: context.vinkol.textPrimary)),
      ),
      body: SafeArea(
        child: VinkolStateView.empty(
          icon: Icons.shopping_bag_outlined,
          title: context.l10n.storeYourCartIsEmpty,
          message: context.l10n.storeAddItemsToGetStarted,
          action: VinkolStateAction(
            label: context.l10n.storeBrowseStores,
            onPressed: onBrowse,
          ),
        ),
      ),
    );
  }
}
