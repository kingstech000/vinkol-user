import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/payment/model/verification_status.dart';

/// The large three-ring badge that carries the verification state.
///
/// Every state draws the same halo, mid-ring and gradient disc; only the
/// colour and the glyph in the middle change. While verifying, the outer halo
/// breathes with [pulseAnimation].
class VerificationStatusIcon extends StatelessWidget {
  final VerificationStatus status;
  final Animation<double> pulseAnimation;

  const VerificationStatusIcon({
    super.key,
    required this.status,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case VerificationStatus.verifying:
        return _badge(
          haloColor: AppColors.primary.withOpacity(0.08),
          ringColor: AppColors.primary.withOpacity(0.15),
          discGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          glowColor: AppColors.primary.withOpacity(0.3),
          pulsing: true,
          child: Center(
            child: SizedBox(
              width: 50.w,
              height: 50.w,
              child: CircularProgressIndicator(
                strokeWidth: 3.w,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        );
      case VerificationStatus.success:
        return _badge(
          haloColor: Colors.green.withOpacity(0.1),
          ringColor: Colors.green.withOpacity(0.15),
          discGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          ),
          glowColor: Colors.green.withOpacity(0.3),
          child:
              Icon(Icons.check_circle_rounded, size: 60.w, color: Colors.white),
        );
      case VerificationStatus.failed:
        return _badge(
          haloColor: Colors.red.withOpacity(0.1),
          ringColor: Colors.red.withOpacity(0.15),
          discGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEF5350), Color(0xFFE57373)],
          ),
          glowColor: Colors.red.withOpacity(0.3),
          child: Icon(Icons.error_rounded, size: 60.w, color: Colors.white),
        );
      case VerificationStatus.timeout:
        return _badge(
          haloColor: Colors.orange.withOpacity(0.1),
          ringColor: Colors.orange.withOpacity(0.15),
          discGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
          ),
          glowColor: Colors.orange.withOpacity(0.3),
          child: Icon(Icons.schedule_rounded, size: 60.w, color: Colors.white),
        );
    }
  }

  Widget _badge({
    required Color haloColor,
    required Color ringColor,
    required Gradient discGradient,
    required Color glowColor,
    required Widget child,
    bool pulsing = false,
  }) {
    final halo = Container(
      width: 160.w,
      height: 160.w,
      decoration: BoxDecoration(color: haloColor, shape: BoxShape.circle),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulsing circle
        if (pulsing)
          ScaleTransition(scale: pulseAnimation, child: halo)
        else
          halo,
        // Middle circle
        Container(
          width: 130.w,
          height: 130.w,
          decoration: BoxDecoration(color: ringColor, shape: BoxShape.circle),
        ),
        // Inner circle with icon
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            gradient: discGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}
