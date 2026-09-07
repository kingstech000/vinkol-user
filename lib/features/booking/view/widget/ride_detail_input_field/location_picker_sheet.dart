// The sheet offering the ways to name a place: search, map, saved.
part of '../ride_detail_input_field.dart';

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
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 32),
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
            icon: Icons.search_rounded,
            title: context.l10n.bookingSearchForAPlace,
            subtitle: context.l10n.bookingTypeAnAddressOrLandmark,
            color: _accent,
            onTap: onSearchTap,
          ),
          const SizedBox(height: 10),
          _SheetOption(
            icon: Icons.map_outlined,
            title: context.l10n.bookingPickOnMap,
            subtitle: context.l10n.bookingDropAPinAnywhere,
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
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
            const Icon(Icons.chevron_right_rounded,
                color: _textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
