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
import 'package:starter_codes/provider/navigation_provider.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// One courier booking, in full.
///
/// The old screen put a map behind everything, which implied a live position the app cannot
/// know — there is no rider-location endpoint (D-10). What replaced it is the honest set:
/// where it is going, how far along it is, who has it, what happened when, and what was paid.
/// Directions to the addresses are still one tap away, because that much *is* real.
class BookingOrderScreen extends ConsumerStatefulWidget {
  const BookingOrderScreen({super.key});

  @override
  ConsumerState<BookingOrderScreen> createState() => _BookingOrderScreenState();
}

class _BookingOrderScreenState extends ConsumerState<BookingOrderScreen> {
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

  void _leave() {
    // Arriving straight from a booking means there is no records screen behind this one to
    // pop back to.
    if (ref.read(comingFromBookingsScreenProvider)) {
      ref.read(comingFromBookingsScreenProvider.notifier).state = false;
      NavigationService.instance
          .navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
    } else {
      NavigationService.instance.goBack();
    }
  }

  Future<void> _cancel(DeliveryModel delivery) async {
    final l10n = context.l10n;
    AppStatusDialogs.showConfirmation(
      context,
      title: l10n.deliveryCancelOrder,
      message: l10n.deliveryCancelOrderBody,
      confirmText: l10n.deliveryCancelConfirm,
      cancelText: l10n.deliveryCancelKeep,
      onConfirm: () async {
        ref.read(isCancellingProvider.notifier).state = true;
        final bool ok = await ref
            .read(deliveryDetailsViewModelProvider.notifier)
            .cancelOrder(delivery.id!);
        ref.read(isCancellingProvider.notifier).state = false;
        if (!mounted) return;
        if (ok) {
          AppStatusDialogs.showSuccess(
              context, l10n.deliveryCancelledTitle, l10n.deliveryCancelledBody);
        } else {
          AppStatusDialogs.showError(context, l10n.deliveryCancelFailedTitle,
              l10n.deliveryCancelFailedBody);
        }
      },
    );
  }

  /// Cancellation is only offered while nobody has the package yet.
  ///
  /// The old condition read `status == pending && agent == null && type == regular ||
  /// type == express`, which binds as `(… ) || express` — so an express order offered
  /// "Cancel" even after it was delivered.
  bool _canCancel(DeliveryModel d) =>
      vinkolStatusFrom(d.status) == VinkolStatus.pending &&
      d.deliveryAgent == null &&
      d.id != null;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final AsyncValue<DeliveryModel?> async =
        ref.watch(deliveryDetailsViewModelProvider);

    return PopScope(
      canPop: !ref.watch(comingFromBookingsScreenProvider),
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        backgroundColor: v.canvas,
        appBar: AppBar(
          backgroundColor: v.canvas,
          surfaceTintColor: v.canvas,
          elevation: 0,
          leading: IconButton(
            onPressed: _leave,
            icon: Icon(Icons.arrow_back, color: v.textPrimary),
          ),
          title: Text(l10n.deliveryPackageDetail,
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
            data: (DeliveryModel? delivery) {
              if (delivery == null) {
                return VinkolStateView.empty(
                  icon: Icons.inbox_outlined,
                  title: l10n.deliveryOrderNotFound,
                  message: l10n.deliveryOrderNotFoundBody,
                  action: VinkolStateAction(
                      label: l10n.deliveryBackToRecords, onPressed: _leave),
                );
              }
              return _Body(
                delivery: delivery,
                canCancel: _canCancel(delivery),
                cancelling: ref.watch(isCancellingProvider),
                onCancel: () => _cancel(delivery),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.delivery,
    required this.canCancel,
    required this.cancelling,
    required this.onCancel,
  });

  final DeliveryModel delivery;
  final bool canCancel;
  final bool cancelling;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final VinkolStatus? status = vinkolStatusFrom(delivery.status);
    final int? step = status == null ? null : trackStepFor(status);
    final String carrier = delivery.deliveryAgent == null
        ? l10n.deliveryNotAssignedYet
        : '${delivery.deliveryAgent!.firstname ?? ''} '
                '${delivery.deliveryAgent!.lastname ?? ''}'
            .trim();

    final double fee = delivery.deliveryFee ?? delivery.amount ?? 0;

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
          badge: l10n.deliveryTrackingId,
          origin: VinkolHeroStop(
            label: l10n.deliveryFrom,
            place: delivery.pickupLocation ?? '—',
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
                    label: l10n.deliveryService,
                    value: delivery.deliveryType ?? delivery.orderType ?? '—',
                  ),
                  VinkolDatum(
                    label: l10n.deliveryVehicle,
                    value:
                        delivery.vehicleType ?? delivery.vehicleRequest ?? '—',
                  ),
                  VinkolDatum(
                    label: l10n.deliveryContents,
                    value: delivery.description?.isNotEmpty == true
                        ? delivery.description!
                        : '—',
                  ),
                  VinkolDatum(
                    label: l10n.deliveryPlaced,
                    value: _placedAt(delivery),
                    numeric: true,
                  ),
                ],
              ),
              // Cancelled and unattended get no track: they are a different outcome, not a
              // step short of one.
              if (step != null) ...<Widget>[
                const SizedBox(height: VinkolSpace.lg),
                Divider(height: 1, color: v.borderSubtle),
                const SizedBox(height: VinkolSpace.lg),
                VinkolProgressTrack(
                  step: step,
                  total: 3,
                  from: delivery.pickupLocation,
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
        if (delivery.deliveryAgent != null) ...<Widget>[
          VinkolSectionHeader(label: l10n.deliveryRider),
          OrderCarrierCard(agent: delivery.deliveryAgent!),
        ],
        VinkolSectionHeader(label: l10n.deliveryStatusHistory),
        OrderStatusHistory(
          status: status,
          carrierStatus: VinkolStatus.withRider,
          createdLabel: _placedAt(delivery),
          currentMeta: carrier,
        ),
        VinkolSectionHeader(label: l10n.deliveryPayment),
        QuoteMoneyCard(
          subtotal: fee,
          lines: <({String amount, String label})>[
            (label: l10n.deliveryDeliveryFee, amount: MarketFormat.money(fee)),
            if (delivery.paymentSource?.isNotEmpty ?? false)
              (label: l10n.deliveryPaidWith, amount: delivery.paymentSource!),
          ],
        ),
        const SizedBox(height: VinkolSpace.xl),
        OrderDetailActions(
          onDirections: () => openGoogleMapsDirections(
              delivery.pickupLocation, delivery.dropoffLocation),
          onGetHelp: () => NavigationService.instance
              .navigateTo(NavigatorRoutes.supportAndHelpScreen),
          onCancel: canCancel ? onCancel : null,
          cancelling: cancelling,
        ),
      ],
    );
  }

  static String _placedAt(DeliveryModel d) {
    final String date = d.date ?? '';
    final String time = d.time ?? '';
    final String joined = '$date $time'.trim();
    return joined.isEmpty ? '—' : joined;
  }
}
