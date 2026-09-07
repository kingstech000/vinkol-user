// The action that commits the trip and goes looking for a rider.
part of '../ride_detail_input_field.dart';

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
              context.l10n.bookingFindRider,
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
