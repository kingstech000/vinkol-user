import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/view/screen/location_search_screen.dart';
import 'package:starter_codes/features/booking/view/screen/map_picker_screen.dart';
import 'package:starter_codes/features/booking/view/widget/order_type_copy.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';

/// The stops form: where the delivery starts and where it ends. The delivery
/// shape was chosen on the screen before, so the header names it. The stops
/// sit on the Line — hollow origin, filled destinations — as white fields on
/// the canvas; the action lives in [FindRiderAction], pinned to the bottom of
/// the screen by [DeliveryStopsScreen].
class RideDetailsInput extends ConsumerWidget {
  const RideDetailsInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideLocationState = ref.watch(rideLocationProvider);
    final rideLocationNotifier = ref.read(rideLocationProvider.notifier);

    Future<void> showLocationSelectionOptions(StopModel stop) async {
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return _LocationPickerSheet(
            stop: stop,
            onSearchTap: () async {
              Navigator.pop(context);
              final LocationModel? pickedLocation = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationSearchScreen(
                      isPickupLocation: stop.isPickup, stopId: stop.id),
                ),
              );
              if (pickedLocation != null) {
                rideLocationNotifier.updateStopLocation(
                    stop.id, pickedLocation);
              }
            },
            onMapTap: () async {
              Navigator.pop(context);
              final LocationModel? pickedLocation = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapPickerScreen(
                      isPickupLocation: stop.isPickup, stopId: stop.id),
                ),
              );
              if (pickedLocation != null) {
                rideLocationNotifier.updateStopLocation(
                    stop.id, pickedLocation);
              }
            },
          );
        },
      );
    }

    final stops = rideLocationState.stops;
    final orderType = rideLocationState.orderType;
    final canAddStop =
        orderType == OrderType.multi || orderType == OrderType.bulk;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            orderType: orderType,
            canSwap: stops.length == 2,
            onSwap: rideLocationNotifier.swapLocations,
          ),
          Gap.h24,
          _StopsList(
            stops: stops,
            orderType: orderType,
            onStopTap: showLocationSelectionOptions,
            onRemove: (stop) => rideLocationNotifier.removeStop(stop.id),
            onClear: (stop) => rideLocationNotifier.clearStopLocation(stop.id),
          ),
          if (canAddStop) ...[
            Gap.h12,
            _AddStopButton(
              label: orderType == OrderType.bulk ? 'Add drop-off' : 'Add order',
              onTap: rideLocationNotifier.addStop,
            ),
          ],
        ],
      ),
    );
  }
}

/// The action for the stops form: full width, anchored at the bottom of the
/// sheet, near-black like the pod. It stays tappable when stops are missing
/// so the tap can say what is missing, rather than sitting there disabled
/// and unexplained.
class FindRiderAction extends ConsumerWidget {
  const FindRiderAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stops = ref.watch(rideLocationProvider).stops;
    final allSelected = stops.every((s) => s.location != null);

    void onTap() {
      if (allSelected) {
        NavigationService.instance
            .navigateTo(NavigatorRoutes.packageInfoScreen);
        return;
      }
      AppStatusDialogs.showError(
          context, 'Stops incomplete', 'Set every stop to find a rider.');
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Semantics(
        button: true,
        label: 'Find a rider',
        child: Material(
          color: VinkolPalette.neutral900,
          borderRadius: BorderRadius.circular(999.r),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 52.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.button(
                    'Find a rider',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: VinkolPalette.white,
                  ),
                  Gap.w8,
                  Icon(
                    PhosphorIconsBold.arrowRight,
                    size: 16.w,
                    color: VinkolPalette.white,
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

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.orderType,
    required this.canSwap,
    required this.onSwap,
  });

  final OrderType orderType;
  final bool canSwap;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.caption(
                '${orderType.title} delivery'.toUpperCase(),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: VinkolPalette.brand600,
                letterSpacing: 0.8,
                maxLines: 1,
              ),
              Gap.h6,
              AppText.h1(
                'Where is it going?',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: VinkolPalette.neutral900,
                letterSpacing: -0.4,
                maxLines: 1,
              ),
              Gap.h6,
              AppText.body(
                orderType.description,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: VinkolPalette.neutral500,
                maxLines: 1,
              ),
            ],
          ),
        ),
        if (canSwap) ...[
          Gap.w12,
          _SwapButton(onTap: onSwap),
        ],
      ],
    );
  }
}

/// Swaps pick-up and drop-off. Hairline chrome, icon bare.
class _SwapButton extends StatelessWidget {
  const _SwapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Swap pick-up and drop-off',
      child: Material(
        color: VinkolPalette.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: VinkolPalette.neutral200),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40.w,
            height: 40.w,
            child: Icon(
              PhosphorIconsRegular.arrowsDownUp,
              size: 20.w,
              color: VinkolPalette.neutral900,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stops — the Line
// ---------------------------------------------------------------------------

class _StopsList extends StatelessWidget {
  const _StopsList({
    required this.stops,
    required this.orderType,
    required this.onStopTap,
    required this.onRemove,
    required this.onClear,
  });

  final List<StopModel> stops;
  final OrderType orderType;
  final void Function(StopModel) onStopTap;
  final void Function(StopModel) onRemove;
  final void Function(StopModel) onClear;

  bool _canRemove(StopModel stop) {
    if (orderType == OrderType.bulk &&
        !stop.isPickup &&
        stops.where((s) => !s.isPickup).length > 1) {
      return true;
    }
    if (orderType == OrderType.multi && stops.length > 2) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < stops.length; i++) ...[
          if (i > 0) const _LineGap(),
          _StopRow(
            stop: stops[i],
            isFirst: i == 0,
            isLast: i == stops.length - 1,
            onTap: () => onStopTap(stops[i]),
            onRemove: _canRemove(stops[i]) ? () => onRemove(stops[i]) : null,
            onClear: stops[i].location != null ? () => onClear(stops[i]) : null,
          ),
        ],
      ],
    );
  }
}

/// The gutter the Line runs down, shared by the rows and the gaps between
/// them so the rule is continuous from the first node to the last.
const _gutterWidth = 16.0;

class _Rule extends StatelessWidget {
  const _Rule({this.visible = true});

  final bool visible;

  @override
  Widget build(BuildContext context) => Container(
        width: 2,
        color: visible ? VinkolPalette.neutral300 : Colors.transparent,
      );
}

/// The space between two fields, with the rule running through it.
class _LineGap extends StatelessWidget {
  const _LineGap();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10.h,
      child: Row(
        children: [
          SizedBox(width: _gutterWidth.w, child: const Center(child: _Rule())),
        ],
      ),
    );
  }
}

/// One stop: its node on the Line, centred on its field, with the rule
/// continuing above and below it except at the ends.
class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.stop,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    this.onRemove,
    this.onClear,
  });

  final StopModel stop;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _gutterWidth.w,
            child: Column(
              children: [
                Expanded(child: _Rule(visible: !isFirst)),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: _Node(isPickup: stop.isPickup),
                ),
                Expanded(child: _Rule(visible: !isLast)),
              ],
            ),
          ),
          Gap.w12,
          Expanded(
            child: _StopField(
              stop: stop,
              onTap: onTap,
              onRemove: onRemove,
              onClear: onClear,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hollow for a pick-up, filled for a drop-off — the same geometry the Line
/// uses everywhere else in the app.
class _Node extends StatelessWidget {
  const _Node({required this.isPickup});

  final bool isPickup;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPickup ? VinkolPalette.white : VinkolPalette.brand500,
        border: Border.all(
          color: isPickup ? VinkolPalette.neutral400 : VinkolPalette.brand500,
          width: 2,
        ),
      ),
    );
  }
}

class _StopField extends StatelessWidget {
  const _StopField({
    required this.stop,
    required this.onTap,
    this.onRemove,
    this.onClear,
  });

  final StopModel stop;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final address = stop.location?.formattedAddress?.trim();
    final hasLocation = address != null && address.isNotEmpty;
    final label = stop.isPickup ? 'Pick-up' : 'Drop-off';

    return Material(
      color: VinkolPalette.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color:
              hasLocation ? VinkolPalette.neutral300 : VinkolPalette.neutral200,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 8.w, 12.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.caption(
                      label.toUpperCase(),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: VinkolPalette.neutral500,
                      letterSpacing: 0.6,
                      maxLines: 1,
                    ),
                    Gap.h4,
                    AppText.body(
                      hasLocation
                          ? address
                          : (stop.isPickup ? 'Where from?' : 'Where to?'),
                      fontSize: 15,
                      fontWeight:
                          hasLocation ? FontWeight.w600 : FontWeight.w500,
                      color: hasLocation
                          ? VinkolPalette.neutral900
                          : VinkolPalette.neutral500,
                      maxLines: 2,
                      lineHeight: 1.3,
                    ),
                  ],
                ),
              ),
              Gap.w8,
              if (onClear != null)
                _FieldAction(
                  icon: PhosphorIconsRegular.x,
                  color: VinkolPalette.neutral600,
                  semanticLabel: 'Clear $label',
                  onTap: onClear!,
                )
              else if (onRemove != null)
                _FieldAction(
                  icon: PhosphorIconsRegular.trash,
                  color: VinkolPalette.dangerText,
                  semanticLabel: 'Remove $label',
                  onTap: onRemove!,
                )
              else
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 6.w),
                  child: Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 16.w,
                    color: VinkolPalette.neutral400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldAction extends StatelessWidget {
  const _FieldAction({
    required this.icon,
    required this.color,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: Icon(icon, size: 16.w, color: color),
        ),
      ),
    );
  }
}

class _AddStopButton extends StatelessWidget {
  const _AddStopButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        // Line up with the fields, past the Line's gutter.
        padding: EdgeInsetsDirectional.only(start: 28.w),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIconsBold.plus,
                    size: 14.w, color: VinkolPalette.brand600),
                Gap.w6,
                AppText.body(
                  label,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.brand600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Location picker sheet
// ---------------------------------------------------------------------------

class _LocationPickerSheet extends StatelessWidget {
  const _LocationPickerSheet({
    required this.stop,
    required this.onSearchTap,
    required this.onMapTap,
  });

  final StopModel stop;
  final VoidCallback onSearchTap;
  final VoidCallback onMapTap;

  @override
  Widget build(BuildContext context) {
    final label = stop.isPickup ? 'pick-up' : 'drop-off';

    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        10.h,
        20.w,
        20.h + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: VinkolPalette.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4,
              decoration: BoxDecoration(
                color: VinkolPalette.neutral300,
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
          Gap.h20,
          Row(
            children: [
              _Node(isPickup: stop.isPickup),
              Gap.w8,
              AppText.h3(
                'Set the $label',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: VinkolPalette.neutral900,
              ),
            ],
          ),
          Gap.h16,
          _SheetOption(
            icon: PhosphorIconsRegular.magnifyingGlass,
            title: 'Search for a place',
            subtitle: 'Type an address or landmark',
            onTap: onSearchTap,
          ),
          Gap.h8,
          _SheetOption(
            icon: PhosphorIconsRegular.mapTrifold,
            title: 'Pick on the map',
            subtitle: 'Drop a pin anywhere',
            onTap: onMapTap,
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VinkolPalette.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: VinkolPalette.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Icon(icon, size: 22.w, color: VinkolPalette.brand600),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.body(
                      title,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: VinkolPalette.neutral900,
                      maxLines: 1,
                    ),
                    Gap.h2,
                    AppText.caption(
                      subtitle,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: VinkolPalette.neutral500,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Gap.w8,
              Icon(PhosphorIconsRegular.caretRight,
                  size: 16.w, color: VinkolPalette.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}
