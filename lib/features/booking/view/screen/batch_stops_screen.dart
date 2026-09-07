import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/view/widget/stops/multistop_widgets.dart';
import 'package:starter_codes/features/booking/view/widget/stops/stop_editor.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Batch — several independent deliveries booked together (`orderType: "Multi"`).
///
/// Each delivery has its own pickup, its own drop-off, its own rider and its own price, so
/// each gets its own card in its own hue. There is no numbering and no reordering here,
/// because unlike multi-drop the order means nothing: these are separate trips that happen
/// to be booked in one go, and one of them failing does not touch the others.
class BatchStopsScreen extends ConsumerStatefulWidget {
  const BatchStopsScreen({super.key});

  @override
  ConsumerState<BatchStopsScreen> createState() => _BatchStopsScreenState();
}

class _BatchStopsScreenState extends ConsumerState<BatchStopsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rideLocationProvider.notifier).convertOrderType(OrderType.multi);
    });
  }

  Future<void> _setLocation(StopModel stop) async {
    final LocationModel? picked = await pickStopLocation(
      context,
      isPickup: stop.isPickup,
      stopId: stop.id,
    );
    if (picked == null || !mounted) return;
    ref.read(rideLocationProvider.notifier).updateStopLocation(stop.id, picked);
    if (!stop.isPickup && stop.recipientName.isEmpty) await _editDetails(stop);
  }

  Future<void> _editDetails(StopModel stop) async {
    final int index = ref.read(rideLocationProvider).dropoffs.indexWhere(
          (StopModel s) => s.id == stop.id,
        );
    final StopDetails? details = await showStopDetailsSheet(
      context,
      stop: stop,
      title: context.l10n.bookingDeliveryNumber(index + 1),
    );
    if (details == null || !mounted) return;
    ref.read(rideLocationProvider.notifier).updateStopDetails(
          stop.id,
          packageName: details.packageName,
          recipientName: details.recipientName,
          recipientPhone: details.recipientPhone,
          note: details.note,
        );
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final RideLocationState state = ref.watch(rideLocationProvider);
    final RideLocationNotifier notifier =
        ref.read(rideLocationProvider.notifier);

    final List<({StopModel pickup, StopModel dropoff})> deliveries =
        state.deliveries;
    final int incomplete = deliveries
        .where((({StopModel pickup, StopModel dropoff}) d) =>
            !d.pickup.isComplete || !d.dropoff.isComplete)
        .length;

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: AppBar(
        backgroundColor: v.canvas,
        surfaceTintColor: v.canvas,
        elevation: 0,
        title: Text(l10n.bookingBatch,
            style: VinkolType.h3.copyWith(color: v.textPrimary)),
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
                  VinkolNotice(
                    headline: l10n.bookingBatchHeadline(deliveries.length),
                    body: l10n.bookingBatchBody,
                  ),
                  VinkolSectionHeader(
                    label: l10n.bookingDeliveries,
                    meta: '${deliveries.length}',
                  ),
                  for (int i = 0; i < deliveries.length; i++)
                    _DeliveryCard(
                      index: i,
                      pickup: deliveries[i].pickup,
                      dropoff: deliveries[i].dropoff,
                      canRemove: deliveries.length > 1,
                      onSetLocation: _setLocation,
                      onEditDetails: _editDetails,
                      onRemove: () =>
                          notifier.removeStop(deliveries[i].pickup.id),
                    ),
                  const SizedBox(height: VinkolSpace.xs),
                  VinkolPrimaryButton(
                    label: l10n.bookingAddADelivery,
                    tone: VinkolButtonTone.quiet,
                    icon: Icons.add,
                    onPressed: notifier.addStop,
                  ),
                  VinkolSectionHeader(label: l10n.bookingOr),
                  SwitchOrderTypeRow(
                    icon: Icons.local_shipping_outlined,
                    title: l10n.bookingSwitchToMultiDropTitle,
                    meta: l10n.bookingSwitchToMultiDropMeta,
                    onTap: () => NavigationService.instance.navigateToReplace(
                        NavigatorRoutes.multidropStopsScreen),
                  ),
                ],
              ),
            ),
            VinkolDock(
              label: l10n.bookingDeliveryCount(deliveries.length),
              detail: incomplete > 0
                  ? l10n.bookingDeliveriesStillNeedDetails(incomplete)
                  : null,
              actionLabel: l10n.bookingGetQuotes,
              onAction: state.isReadyForQuote
                  ? () => NavigationService.instance
                      .navigateTo(NavigatorRoutes.packageInfoScreen)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// One delivery in the batch, in its own hue.
///
/// The hue is the only thing tying this card to a line on the quote map, so it comes from
/// the shared order ramp and the card states its number in words as well — colour is the
/// third signal here, never the only one.
class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    required this.index,
    required this.pickup,
    required this.dropoff,
    required this.canRemove,
    required this.onSetLocation,
    required this.onEditDetails,
    required this.onRemove,
  });

  final int index;
  final StopModel pickup;
  final StopModel dropoff;
  final bool canRemove;
  final void Function(StopModel) onSetLocation;
  final void Function(StopModel) onEditDetails;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final Color hue = v.orderHues[index % v.orderHues.length];

    return Container(
      margin: const EdgeInsets.only(bottom: VinkolSpace.md),
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brMd,
        border: BorderDirectional(
          top: BorderSide(color: v.borderSubtle),
          end: BorderSide(color: v.borderSubtle),
          bottom: BorderSide(color: v.borderSubtle),
          start: BorderSide(color: hue, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(VinkolSpace.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: hue,
                    borderRadius: VinkolRadius.brFull,
                  ),
                ),
                const SizedBox(width: VinkolSpace.iconToLabel),
                Expanded(
                  child: Text(
                    l10n.bookingDeliveryNumber(index + 1),
                    style: VinkolType.h4.copyWith(color: v.textPrimary),
                  ),
                ),
                if (canRemove)
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: IconButton(
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      tooltip: l10n.bookingRemoveDelivery,
                      icon: Icon(Icons.close, size: 18, color: v.textTertiary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: VinkolSpace.md),
            VinkolStopsRail(
              stops: <VinkolStop>[
                VinkolStop(
                  label: l10n.bookingPickup,
                  place: pickup.location?.formattedAddress,
                  placeholder: l10n.bookingWhereAreWeCollectingFrom,
                  onTap: () => onSetLocation(pickup),
                ),
                VinkolStop(
                  label: l10n.bookingDropOff,
                  place: dropoff.location?.formattedAddress,
                  placeholder: l10n.bookingWhereIsItGoing,
                  onTap: () => dropoff.location == null
                      ? onSetLocation(dropoff)
                      : onEditDetails(dropoff),
                ),
              ],
            ),
            const SizedBox(height: VinkolSpace.md),
            Text(
              dropoff.isComplete
                  ? '${dropoff.recipientName} · ${dropoff.packageName}'
                  : l10n.bookingAddRecipientAndPackage,
              style: VinkolType.bodyS.copyWith(color: v.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
