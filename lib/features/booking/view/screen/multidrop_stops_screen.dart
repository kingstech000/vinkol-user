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

/// Multi-drop — one pickup, several drop-offs, chained into one route (`orderType: "Bulk"`).
///
/// The list is numbered and reorderable because in this product the order of the stops is
/// not a display preference: the route is chained, so moving stop three above stop two
/// changes the distance and therefore the price. That is the whole difference between this
/// screen and the batch editor, and it is why the two are not one screen with a toggle.
class MultidropStopsScreen extends ConsumerStatefulWidget {
  const MultidropStopsScreen({super.key});

  @override
  ConsumerState<MultidropStopsScreen> createState() =>
      _MultidropStopsScreenState();
}

class _MultidropStopsScreenState extends ConsumerState<MultidropStopsScreen> {
  @override
  void initState() {
    super.initState();
    // Entering the editor is what declares the type; the stops carry over.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rideLocationProvider.notifier).convertOrderType(OrderType.bulk);
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

    // An address with no recipient cannot be quoted, so ask for the rest while the user is
    // still thinking about this stop rather than at the end of the flow.
    if (!stop.isPickup && stop.recipientName.isEmpty) await _editDetails(stop);
  }

  Future<void> _editDetails(StopModel stop) async {
    final int index = ref.read(rideLocationProvider).dropoffs.indexWhere(
          (StopModel s) => s.id == stop.id,
        );
    final StopDetails? details = await showStopDetailsSheet(
      context,
      stop: stop,
      title: context.l10n.bookingStopNumber(index + 1),
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

    final StopModel? pickup = state.pickups.firstOrNull;
    final List<StopModel> dropoffs = state.dropoffs;
    final int incomplete =
        dropoffs.where((StopModel s) => !s.isComplete).length;

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: AppBar(
        backgroundColor: v.canvas,
        surfaceTintColor: v.canvas,
        elevation: 0,
        title: Text(l10n.bookingMultiDrop,
            style: VinkolType.h3.copyWith(color: v.textPrimary)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: VinkolSpace.pageMargin),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: VinkolSpace.sm),
                          VinkolNotice(
                            headline:
                                l10n.bookingMultiDropHeadline(dropoffs.length),
                            body: l10n.bookingMultiDropBody,
                          ),
                          VinkolSectionHeader(label: l10n.bookingPickup),
                          if (pickup != null)
                            VinkolRowGroup(
                              children: <VinkolRow>[
                                VinkolRow(
                                  title: pickup.location?.formattedAddress ??
                                      l10n.bookingWhereAreWeCollectingFrom,
                                  meta: l10n.bookingCollectEverythingHere,
                                  icon: Icons.trip_origin,
                                  accentIcon: true,
                                  onTap: () => _setLocation(pickup),
                                ),
                              ],
                            ),
                          VinkolSectionHeader(
                            label: l10n.bookingDropOffs,
                            meta: '${dropoffs.length}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: VinkolSpace.pageMargin),
                    sliver: SliverReorderableList(
                      itemCount: dropoffs.length,
                      onReorder: notifier.reorderDropoffs,
                      itemBuilder: (BuildContext context, int index) {
                        final StopModel stop = dropoffs[index];
                        return _DropoffTile(
                          key: ValueKey<String>(stop.id),
                          index: index,
                          stop: stop,
                          canRemove: dropoffs.length > 1,
                          onSetLocation: () => _setLocation(stop),
                          onEditDetails: () => _editDetails(stop),
                          onRemove: () => notifier.removeStop(stop.id),
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      VinkolSpace.pageMargin,
                      VinkolSpace.md,
                      VinkolSpace.pageMargin,
                      VinkolSpace.xxl,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          VinkolPrimaryButton(
                            label: l10n.bookingAddADropOff,
                            tone: VinkolButtonTone.quiet,
                            icon: Icons.add,
                            onPressed: notifier.addStop,
                          ),
                          VinkolSectionHeader(label: l10n.bookingOr),
                          SwitchOrderTypeRow(
                            icon: Icons.storefront_outlined,
                            title: l10n.bookingSwitchToBatchTitle,
                            meta: l10n.bookingSwitchToBatchMeta,
                            onTap: () => NavigationService.instance
                                .navigateToReplace(
                                    NavigatorRoutes.batchStopsScreen),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            VinkolDock(
              label: l10n.bookingDropOffCount(dropoffs.length),
              detail: incomplete > 0
                  ? l10n.bookingStopsStillNeedDetails(incomplete)
                  : null,
              actionLabel: l10n.bookingGetQuote,
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

/// One numbered drop-off. The number is its position in the route, not an id.
///
/// Purpose-built rather than a [VinkolRow], because a row truncates its title to one line and
/// here the title is a street address — the content of the screen, not a label for it. The
/// number leads: a chained route is read down the leading edge, and it is the order that sets
/// the price.
class _DropoffTile extends StatelessWidget {
  const _DropoffTile({
    super.key,
    required this.index,
    required this.stop,
    required this.canRemove,
    required this.onSetLocation,
    required this.onEditDetails,
    required this.onRemove,
  });

  final int index;
  final StopModel stop;
  final bool canRemove;
  final VoidCallback onSetLocation;
  final VoidCallback onEditDetails;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final bool hasLocation = stop.location != null;

    final String meta = !hasLocation
        ? l10n.bookingWhereIsItGoing
        : stop.isComplete
            ? '${stop.recipientName} · ${stop.packageName}'
            : l10n.bookingAddRecipientAndPackage;

    return Padding(
      padding: const EdgeInsets.only(bottom: VinkolSpace.sm),
      child: Container(
        decoration: BoxDecoration(
          color: v.surface,
          borderRadius: VinkolRadius.brMd,
          border: VinkolElevation.hairline(v),
        ),
        child: Semantics(
          button: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: hasLocation ? onEditDetails : onSetLocation,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(VinkolSpace.lg,
                  VinkolSpace.md, VinkolSpace.xs, VinkolSpace.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  StopMarker(label: '${index + 1}'),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          stop.location?.formattedAddress ??
                              l10n.bookingWhereIsItGoing,
                          style: VinkolType.h4.copyWith(
                            color: hasLocation ? v.textPrimary : v.textTertiary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: VinkolSpace.xxs),
                        Text(
                          meta,
                          style:
                              VinkolType.bodyS.copyWith(color: v.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: Tooltip(
                      message: l10n.bookingReorderStops,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(Icons.drag_handle,
                            size: 19, color: v.textTertiary),
                      ),
                    ),
                  ),
                  if (canRemove)
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: IconButton(
                        onPressed: onRemove,
                        padding: EdgeInsets.zero,
                        tooltip: l10n.bookingRemoveStop,
                        icon:
                            Icon(Icons.close, size: 18, color: v.textTertiary),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
