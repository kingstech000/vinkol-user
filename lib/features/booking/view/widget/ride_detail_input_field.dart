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
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    final isMulti = rideLocationState.orderType == OrderType.multi;
    final isBulk = rideLocationState.orderType == OrderType.bulk;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _accentDim,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(PhosphorIconsRegular.path, color: _accent, size: 18),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book Your Ride',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Set your stops below',
                      style: TextStyle(
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
                      child: const Icon(PhosphorIconsRegular.arrowsDownUp,
                          color: _accent, size: 20),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ModeSelector(
              state: rideLocationState,
              notifier: rideLocationNotifier,
            ),
          ),
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                      content: const Text('Please select all stop locations.'),
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

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.state, required this.notifier});

  final RideLocationState state;
  final RideLocationNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: OrderType.values.map((type) {
          final isSelected = state.orderType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => notifier.setOrderType(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? _accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text(
                  type.name.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? _textOnAccent : _textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StopsList extends StatelessWidget {
  const _StopsList({
    required this.stops,
    required this.onStopTap,
    required this.onRemove,
    required this.onClear,
    required this.orderType,
  });

  final List<StopModel> stops;
  final void Function(StopModel) onStopTap;
  final void Function(StopModel) onRemove;
  final void Function(StopModel) onClear;
  final OrderType orderType;

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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: stops.asMap().entries.map((entry) {
                final index = entry.key;
                final stop = entry.value;
                final isLast = index == stops.length - 1;

                return Expanded(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 14,
                      ),
                      _StopDot(isPickup: stop.isPickup),
                      if (!isLast)
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 1.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    stop.isPickup
                                        ? _accent.withOpacity(0.6)
                                        : _red.withOpacity(0.6),
                                    _border,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: stops.asMap().entries.map((entry) {
                final index = entry.key;
                final stop = entry.value;
                final isLast = index == stops.length - 1;

                return Column(
                  children: [
                    _StopInputField(
                      stop: stop,
                      onTap: () => onStopTap(stop),
                      onRemove: _canRemove(stop) ? () => onRemove(stop) : null,
                      onClear:
                          stop.location != null ? () => onClear(stop) : null,
                    ),
                    if (!isLast) const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StopDot extends StatelessWidget {
  const _StopDot({required this.isPickup});

  final bool isPickup;

  @override
  Widget build(BuildContext context) {
    final color = isPickup ? _accent : _red;
    final bgColor = isPickup ? _accentDim : _redDim;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _StopInputField extends StatelessWidget {
  const _StopInputField({
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
    final hasLocation = stop.location != null;
    final color = stop.isPickup ? _accent : _red;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: hasLocation ? _surfaceElevated : _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasLocation ? color.withOpacity(0.35) : _border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                stop.isPickup ? 'FROM' : 'TO',
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                stop.location?.formattedAddress ??
                    (stop.isPickup ? 'Pick-up location' : 'Drop-off location'),
                style: TextStyle(
                  color: hasLocation ? _textPrimary : _textSecondary,
                  fontSize: 13,
                  fontWeight: hasLocation ? FontWeight.w500 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _accentDim,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child:
                      const Icon(PhosphorIconsRegular.x, size: 14, color: _accent),
                ),
              )
            else if (onRemove != null)
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _redDim,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(PhosphorIconsRegular.trash,
                      size: 14, color: _red),
                ),
              )
            else
              Icon(
                hasLocation
                    ? PhosphorIconsFill.checkCircle
                    : PhosphorIconsRegular.caretRight,
                color: hasLocation ? color : _textMuted,
                size: 18,
              ),
          ],
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
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _accentDim,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(PhosphorIconsRegular.plus, color: _accent, size: 14),
          ),
          const SizedBox(width: 8),
          AppText.h2(
            label,
            color: _accent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

class _FindRiderButton extends StatelessWidget {
  const _FindRiderButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText.body(
              'Find Rider',
              color: _textOnAccent,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ],
        ),
      ),
    );
  }
}

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
    final color = stop.isPickup ? _accent : _red;
    final label = stop.isPickup ? 'Pick-up' : 'Drop-off';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'Set $label Location',
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Options
          _SheetOption(
            icon: PhosphorIconsRegular.magnifyingGlass,
            title: 'Search for a place',
            subtitle: 'Type an address or landmark',
            color: _accent,
            onTap: onSearchTap,
          ),
          const SizedBox(height: 10),
          _SheetOption(
            icon: PhosphorIconsRegular.mapTrifold,
            title: 'Pick on map',
            subtitle: 'Drop a pin anywhere',
            color: const Color(0xFF6E8FFF),
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
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(PhosphorIconsRegular.caretRight,
                color: _textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
