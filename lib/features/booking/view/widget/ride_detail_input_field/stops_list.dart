// The editable list of stops on the trip, and the controls that grow it.
part of '../ride_detail_input_field.dart';

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
                      const Icon(Icons.close_rounded, size: 14, color: _accent),
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
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 14, color: _red),
                ),
              )
            else
              Icon(
                hasLocation
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
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
            child: const Icon(Icons.add_rounded, color: _accent, size: 14),
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
