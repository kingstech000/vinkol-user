import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';

/// A control floating on the map: white, hairline, no shadow, the icon bare.
/// It fades out (and stops taking taps) once the sheet has covered the map.
class MapControl extends StatelessWidget {
  const MapControl({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.hidden = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      ignoring: hidden,
      child: AnimatedOpacity(
        opacity: hidden ? 0 : 1,
        duration: Duration(milliseconds: reduceMotion ? 0 : 140),
        curve: Curves.easeOutCubic,
        child: Semantics(
          button: true,
          label: semanticLabel,
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
                width: 44.w,
                height: 44.w,
                child: Icon(icon, size: 20.w, color: VinkolPalette.neutral900),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
