import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart'; // Assuming AppColors is here

class BorderedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final double? iconSize;
  final Color? borderColor;
  final double? borderWidth;
  final double? padding; // Padding inside the button

  const BorderedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.iconSize,
    this.borderColor,
    this.borderWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? Colors.grey.shade300, // Default border color
          width: borderWidth ?? 1.w, // Default border width
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor ?? AppColors.white, // Default icon color
          size: iconSize ?? 15.w, // Default icon size
        ),
        onPressed: onPressed,
        padding:
            EdgeInsets.all(padding ?? 0.w), // Default padding for IconButton
      ),
    );
  }
}
