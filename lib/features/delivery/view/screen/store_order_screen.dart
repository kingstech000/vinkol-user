import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/map_utils.dart';
import 'package:starter_codes/features/booking/view/widget/quote/quote_summary.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/features/delivery/view/widget/detail/order_detail_widgets.dart';
import 'package:starter_codes/features/delivery/view_model/delivery_detail_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/l10n/status_labels.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// One store order — `orderType: "Shopping"`.
///
/// The same shape as a courier booking with one section swapped: what was bought sits where
/// the package description would be, and the carrier is a shopper gathering an order rather
/// than a rider carrying one. The lifecycle genuinely differs, which is why it is a separate
/// screen rather than a flag on the other one.
class StoreOrderScreen extends ConsumerStatefulWidget {
  const StoreOrderScreen({super.key});

  @override
  ConsumerState<StoreOrderScreen> createState() => _StoreOrderScreenState();
}

class _StoreOrderScreenState extends ConsumerState<StoreOrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final DeliveryModel? selected = ref.read(selectedDeliveryProvider);
      if (selected?.id == null) return;
      ref
          .read(deliveryDetailsViewModelProvider.notifier)
          .fetchDeliveryById(selected!.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final AsyncValue<DeliveryModel?> async =
        ref.watch(deliveryDetailsViewModelProvider);

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: AppBar(
        backgroundColor: v.canvas,
        surfaceTintColor: v.canvas,
        elevation: 0,
        title: Text(l10n.deliveryStoreOrder,
            style: VinkolType.h3.copyWith(color: v.textPrimary)),
      ),
      body: SafeArea(
        top: false,
        child: async.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(horizontal: VinkolSpace.pageMargin),
            child: VinkolSkeletonList(shape: VinkolSkeletonShape.record),
          ),
          error: (Object error, StackTrace stack) => VinkolStateView.error(
            title: l10n.deliveryCouldNotLoadOrder,
            message: error.toString(),
            action: VinkolStateAction(
              label: l10n.commonTryAgain,
              onPressed: () {
                final DeliveryModel? selected =
                    ref.read(selectedDeliveryProvider);
                if (selected?.id == null) return;
                ref
                    .read(deliveryDetailsViewModelProvider.notifier)
                    .fetchDeliveryById(selected!.id!);
              },
            ),
          ),
          data: (DeliveryModel? delivery) => delivery == null
              ? VinkolStateView.empty(
                  icon: Icons.inbox_outlined,
                  title: l10n.deliveryOrderNotFound,
                  message: l10n.deliveryOrderNotFoundBody,
                  action: VinkolStateAction(
                    label: l10n.deliveryBackToRecords,
                    onPressed: () => NavigationService.instance.goBack(),
                  ),
                )
              : _Body(delivery: delivery),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.delivery});

  final DeliveryModel delivery;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final VinkolStatus? status = vinkolStatusFrom(delivery.status);
    final int? step = status == null ? null : trackStepFor(status);
    final List<ProductModel> products = delivery.products ?? <ProductModel>[];

    final double subtotal = delivery.amount ??
        products.fold<double>(
            0,
            (double s, ProductModel p) =>
                s + (p.price ?? 0) * (p.quantity ?? 0));
    final double fee = delivery.deliveryFee ?? 0;

    final String carrier = delivery.deliveryAgent == null
        ? (delivery.store?.name ?? l10n.deliveryNotAssignedYet)
        : '${delivery.deliveryAgent!.firstname ?? ''} '
                '${delivery.deliveryAgent!.lastname ?? ''}'
            .trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        VinkolSpace.pageMargin,
        VinkolSpace.sm,
        VinkolSpace.pageMargin,
        VinkolSpace.xxl,
      ),
      children: <Widget>[
        VinkolHeroCard(
          eyebrow: status?.labelIn(context) ?? l10n.deliveryInProgress,
          live: isLiveStatus(status),
          reference: delivery.trackingId,
          badge: l10n.deliveryItemCount(products.length),
          origin: VinkolHeroStop(
            label: l10n.deliveryFromStore,
            place: delivery.store?.name ?? delivery.pickupLocation ?? '—',
          ),
          destination: VinkolHeroStop(
            label: l10n.deliveryTo,
            place: delivery.dropoffLocation ?? '—',
          ),
        ),
        const SizedBox(height: VinkolSpace.md),
        Container(
          padding: const EdgeInsets.all(VinkolSpace.cardPadding),
          decoration: BoxDecoration(
            color: v.surface,
            borderRadius: VinkolRadius.brMd,
            border: VinkolElevation.hairline(v),
          ),
          child: Column(
            children: <Widget>[
              VinkolDataGrid(
                data: <VinkolDatum>[
                  VinkolDatum(
                    label: l10n.deliveryStore,
                    value: delivery.store?.name ?? '—',
                  ),
                  VinkolDatum(
                    label: l10n.deliveryPlaced,
                    value: _placedAt(delivery),
                    numeric: true,
                  ),
                  VinkolDatum(
                    label: l10n.deliveryPickupFrom,
                    value: delivery.store?.address ??
                        delivery.pickupLocation ??
                        '—',
                  ),
                  VinkolDatum(
                    label: l10n.deliveryDeliverTo,
                    value: delivery.dropoffLocation ?? '—',
                  ),
                ],
              ),
              if (step != null) ...<Widget>[
                const SizedBox(height: VinkolSpace.lg),
                Divider(height: 1, color: v.borderSubtle),
                const SizedBox(height: VinkolSpace.lg),
                VinkolProgressTrack(
                  step: step,
                  total: 3,
                  from: delivery.store?.name ?? delivery.pickupLocation,
                  to: delivery.dropoffLocation,
                ),
              ],
            ],
          ),
        ),
        if (delivery.trackingId?.isNotEmpty ?? false) ...<Widget>[
          const SizedBox(height: VinkolSpace.md),
          TrackingIdRow(trackingId: delivery.trackingId!),
        ],
        if (products.isNotEmpty) ...<Widget>[
          VinkolSectionHeader(
            label: l10n.storeItems,
            meta: '${products.length}',
          ),
          VinkolRowGroup(
            children: <VinkolRow>[
              for (final ProductModel product in products)
                VinkolRow(
                  title: product.title ?? '—',
                  meta: l10n.storeTimesPrice(
                    product.quantity ?? 1,
                    MarketFormat.money(product.price ?? 0),
                  ),
                  value: MarketFormat.money(
                      (product.price ?? 0) * (product.quantity ?? 1)),
                  titleMaxLines: 2,
                ),
            ],
          ),
        ],
        if (delivery.deliveryAgent != null) ...<Widget>[
          VinkolSectionHeader(label: l10n.deliveryShopper),
          OrderCarrierCard(agent: delivery.deliveryAgent!),
        ],
        VinkolSectionHeader(label: l10n.deliveryStatusHistory),
        OrderStatusHistory(
          status: status,
          carrierStatus: VinkolStatus.withShopper,
          createdLabel: _placedAt(delivery),
          currentMeta: carrier,
        ),
        VinkolSectionHeader(label: l10n.deliveryPayment),
        QuoteMoneyCard(
          subtotal: subtotal + fee,
          lines: <({String amount, String label})>[
            (label: l10n.storeSubtotal, amount: MarketFormat.money(subtotal)),
            (label: l10n.storeDeliveryFee, amount: MarketFormat.money(fee)),
            if (delivery.paymentSource?.isNotEmpty ?? false)
              (label: l10n.deliveryPaidWith, amount: delivery.paymentSource!),
          ],
        ),
        const SizedBox(height: VinkolSpace.xl),
        OrderDetailActions(
          onDirections: () => openGoogleMapsDirections(
              delivery.store?.address ?? delivery.pickupLocation,
              delivery.dropoffLocation),
          onGetHelp: () => NavigationService.instance
              .navigateTo(NavigatorRoutes.supportAndHelpScreen),
        ),
      ],
    );
  }

  static String _placedAt(DeliveryModel d) {
    final String joined = '${d.date ?? ''} ${d.time ?? ''}'.trim();
    return joined.isEmpty ? '—' : joined;
  }
}
