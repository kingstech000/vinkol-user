// lib/screens/home/widgets/ride_details_input.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/features/booking/view/screen/location_search_screen.dart';
import 'package:starter_codes/features/booking/view/screen/map_picker_screen.dart';
import 'package:starter_codes/l10n/l10n.dart';

part 'ride_detail_input_field/mode_selector.dart';
part 'ride_detail_input_field/stops_list.dart';
part 'ride_detail_input_field/find_rider_button.dart';
part 'ride_detail_input_field/location_picker_sheet.dart';

const _white = AppColors.white;
const _surface = Color(0xFFF8F9FB);
const _surfaceElevated = AppColors.white;
const _border = Color(0xFFE8ECF2);
const _accent = AppColors.primary;
const _accentDim = Color(0xFFE7F1FB);
const _red = AppColors.red;
const _redDim = Color(0xFFFDECEB);
const _textPrimary = AppColors.black;
const _textSecondary = Color(0xFF64748B);
const _textMuted = Color(0xFF94A3B8);
const _textOnAccent = AppColors.white;

/// What each order type is called to a user.
///
/// The API's names — "Delivery", "Bulk", "Multi" — describe the shape of the payload, which
/// is why the flow has never been discoverable. These describe the job.
String _orderTypeLabel(BuildContext context, OrderType type) {
  switch (type) {
    case OrderType.standard:
      return context.l10n.bookingOneDropOff;
    case OrderType.bulk:
      return context.l10n.bookingMultiDrop;
    case OrderType.multi:
      return context.l10n.bookingBatch;
  }
}

class RideDetailsInput extends ConsumerWidget {
  const RideDetailsInput({super.key, this.embedded = false});

  /// Hosted inside a screen that has already established the service and titled itself, so
  /// the card's own header and mode selector would be asking the same question twice.
  final bool embedded;

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
    final isMulti = rideLocationState.orderType == OrderType.multi;
    final isBulk = rideLocationState.orderType == OrderType.bulk;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (embedded) const SizedBox(height: 20),
          if (!embedded)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _accentDim,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.route_rounded,
                        color: _accent, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.bookingBookYourRide,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        context.l10n.bookingSetYourStopsBelow,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  if (stops.length == 2) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: () => rideLocationNotifier.swapLocations(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _accentDim,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _accent.withOpacity(0.1)),
                        ),
                        child: const Icon(Icons.swap_vert_rounded,
                            color: _accent, size: 20),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (!embedded) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ModeSelector(
                state: rideLocationState,
                notifier: rideLocationNotifier,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _StopsList(
              stops: stops,
              onStopTap: showLocationSelectionOptions,
              onRemove: (stop) => rideLocationNotifier.removeStop(stop.id),
              onClear: (stop) =>
                  rideLocationNotifier.clearStopLocation(stop.id),
              orderType: rideLocationState.orderType,
            ),
          ),
          if (isMulti || isBulk) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _AddStopButton(
                label: isBulk ? 'Add Drop-off' : 'Add Order',
                onTap: () => rideLocationNotifier.addStop(),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
            child: _FindRiderButton(
              onTap: () {
                final allSelected =
                    rideLocationState.stops.every((s) => s.location != null);
                if (allSelected) {
                  NavigationService.instance
                      .navigateTo(NavigatorRoutes.packageInfoScreen);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          context.l10n.bookingPleaseSelectAllStopLocations),
                      backgroundColor: _surfaceElevated,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
