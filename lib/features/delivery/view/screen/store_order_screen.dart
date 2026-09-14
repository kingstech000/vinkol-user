import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/map_utils.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/features/delivery/model/order_status.dart';
import 'package:starter_codes/features/delivery/view/widget/order_detail_widgets.dart';
import 'package:starter_codes/features/delivery/view_model/delivery_detail_view_model.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/provider/navigation_provider.dart';
import 'package:starter_codes/widgets/content_sized_sheet.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/map_control.dart';
import 'package:starter_codes/widgets/reverse_map.dart';

/// A store order on its own screen, built from the same pieces as a package
/// delivery so the two read as one product: the route from the store on a
/// full-bleed map, and a sheet that answers where it is, who has it, what was
/// bought, where it is going, what it cost, and what the customer needs at
/// handover. Everything on it is a field the API returns (decision D-10).
class StoreOrderScreen extends ConsumerStatefulWidget {
  const StoreOrderScreen({super.key});

  @override
  ConsumerState<StoreOrderScreen> createState() => _StoreOrderScreenState();
}

class _StoreOrderScreenState extends ConsumerState<StoreOrderScreen> {
  /// Past this extent the sheet is under the map controls, so they step aside.
  static const _controlsHideAt = 0.82;

  bool _controlsHidden = false;

  void _onSheetExtent(double extent) {
    final hidden = extent >= _controlsHideAt;
    if (hidden != _controlsHidden) setState(() => _controlsHidden = hidden);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedDelivery = ref.read(selectedDeliveryProvider);
      if (selectedDelivery != null && selectedDelivery.id != null) {
        ref
            .read(deliveryDetailsViewModelProvider.notifier)
            .fetchDeliveryById(selectedDelivery.id!);
      } else {
        debugPrint('Error: No delivery selected or ID is null.');
      }
    });
  }

  void _goBack() {
    if (ref.read(comingFromBookingsScreenProvider)) {
      ref.read(comingFromBookingsScreenProvider.notifier).state = false;
      NavigationService.instance
          .navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
    } else {
      NavigationService.instance.goBack();
    }
  }

  void _openGoogleMapsDirections() {
    final delivery = ref.read(deliveryDetailsViewModelProvider).value;
    if (delivery == null) return;
    openGoogleMapsDirections(_pickupOf(delivery), delivery.dropoffLocation);
  }

  @override
  Widget build(BuildContext context) {
    final deliveryDetailsAsync = ref.watch(deliveryDetailsViewModelProvider);
    final isFromBookingScreen = ref.watch(comingFromBookingsScreenProvider);

    return PopScope(
      canPop: !isFromBookingScreen,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 76.w,
          leading: Padding(
            padding: EdgeInsetsDirectional.only(start: 20.w),
            child: Center(
              child: MapControl(
                icon: PhosphorIconsRegular.caretLeft,
                semanticLabel: 'Back',
                hidden: _controlsHidden,
                onTap: _goBack,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 20.w),
              child: Center(
                child: MapControl(
                  icon: PhosphorIconsRegular.navigationArrow,
                  semanticLabel: 'Open directions',
                  hidden: _controlsHidden,
                  onTap: _openGoogleMapsDirections,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: deliveryDetailsAsync.when(
                data: (delivery) {
                  if (delivery == null) return const OrderMapPlaceholder();
                  return ReverseLocationStringMap(
                    pickupLocationString: _pickupOf(delivery),
                    dropoffLocationString: delivery.dropoffLocation,
                  );
                },
                loading: () => const OrderMapPlaceholder(),
                error: (err, stack) => const OrderMapPlaceholder(),
              ),
            ),
            ContentSizedSheet(
              color: AppColors.background,
              onExtentChanged: _onSheetExtent,
              child: deliveryDetailsAsync.when(
                data: (delivery) => delivery == null
                    ? const OrderSheetMessage(
                        icon: PhosphorIconsRegular.bag,
                        message: 'No store order details found',
                      )
                    : _SheetBody(delivery: delivery),
                loading: () => SizedBox(
                  height: 160.h,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (err, stack) => const OrderSheetMessage(
                  icon: PhosphorIconsRegular.warningCircle,
                  message: 'Unable to load order details',
                  isError: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Where the rider collects from. The store's own address when the server
/// populated the store; otherwise the pickup the order was written with.
String? _pickupOf(DeliveryModel delivery) {
  final storeAddress = delivery.store?.address?.trim();
  if (storeAddress != null && storeAddress.isNotEmpty) return storeAddress;
  return delivery.pickupLocation;
}

// ---------------------------------------------------------------------------
// Sheet body
// ---------------------------------------------------------------------------

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.delivery});

  final DeliveryModel delivery;

  /// `Store order · Express · 3 items` — only the parts the order carries.
  String get _subtitle {
    final parts = <String>['Store order'];
    final type = delivery.deliveryType?.trim();
    if (type != null && type.isNotEmpty) parts.add(orderTitleCase(type));
    final count = delivery.totalItemsOrdered;
    if (count > 0) parts.add(count == 1 ? '1 item' : '$count items');
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final status = OrderStatus.parse(delivery.status);
    final agent = delivery.deliveryAgent;
    final showAgent = agent != null && status.kind != OrderStatusKind.delivered;
    final products = delivery.products ?? const <ProductModel>[];
    final store = delivery.store;
    final amount = delivery.amount;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        4.h,
        20.w,
        20.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderHeaderCard(
            delivery: delivery,
            status: status,
            subtitle: _subtitle,
          ),
          Gap.h12,
          if (showAgent) ...[
            OrderAgentCard(
              agent: agent,
              // The same person is a shopper while the goods are being bought
              // and a rider once they are on the road; the server's status is
              // what says which.
              label: status.kind == OrderStatusKind.withShopper
                  ? 'Your shopper'
                  : 'Your rider',
            ),
            Gap.h12,
          ],
          if (products.isNotEmpty) ...[
            _ItemsCard(products: products, currency: delivery.currency),
            Gap.h12,
          ],
          OrderDetailCard(
            child: OrderRouteLine(stops: [
              OrderStop(
                label: 'Pick-up',
                title: store?.name,
                address: _pickupOf(delivery),
                isOrigin: true,
              ),
              OrderStop(
                label: 'Drop-off',
                address: delivery.dropoffLocation,
              ),
            ]),
          ),
          Gap.h12,
          OrderSummaryCard(
            delivery: delivery,
            subtotal: amount == null ? null : Money(amount, delivery.currency),
          ),
          if (delivery.orderOtp != null &&
              status.isOnTrack &&
              status.kind != OrderStatusKind.delivered) ...[
            Gap.h12,
            OrderDeliveryCode(code: delivery.orderOtp!),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Items — what was bought
// ---------------------------------------------------------------------------

/// The goods, one row each: what it is, how many, and what that line cost.
/// The detail endpoint populates each product's title, price and photo; where
/// an older record carries only ids, the row still shows the quantity so the
/// count on the card stays true.
class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.products, required this.currency});

  final List<ProductModel> products;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final count = products.fold<int>(0, (sum, p) => sum + (p.quantity ?? 0));

    return OrderDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: OrderDetailLabel('Items')),
              AppText.caption(
                count == 1 ? '1 item' : '$count items',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: VinkolPalette.neutral500,
              ),
            ],
          ),
          Gap.h12,
          for (var i = 0; i < products.length; i++) ...[
            if (i > 0) ...[Gap.h10, const OrderHairline(), Gap.h10],
            _ItemRow(product: products[i], currency: currency),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.product, required this.currency});

  final ProductModel product;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final title = product.title?.trim();
    final quantity = product.quantity ?? 1;
    final price = product.price;
    final lineTotal = price == null ? null : Money(price * quantity, currency);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ItemThumbnail(imageUrl: product.imageUrl),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.body(
                title == null || title.isEmpty ? 'Item' : title,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: VinkolPalette.neutral900,
                maxLines: 2,
                lineHeight: 1.3,
              ),
              Gap.h2,
              AppText.caption(
                price == null
                    ? 'Qty $quantity'
                    : 'Qty $quantity · ${Money(price, currency).format()}',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: VinkolPalette.neutral500,
                maxLines: 1,
              ),
            ],
          ),
        ),
        if (lineTotal != null) ...[
          Gap.w12,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.body(
                lineTotal.currency.symbol,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: VinkolPalette.neutral500,
              ),
              AppText.h3(
                lineTotal.format(showSymbol: false),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: VinkolPalette.neutral900,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// The product photo on a tinted ground, or a bag glyph on the same ground
/// when the record has none — so every row keeps the same left edge.
class _ItemThumbnail extends StatelessWidget {
  const _ItemThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    final placeholder = Icon(
      PhosphorIconsRegular.bag,
      size: 20.w,
      color: VinkolPalette.neutral400,
    );

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: VinkolPalette.neutral50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null || url.isEmpty
          ? placeholder
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder,
            ),
    );
  }
}
