import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';

class AppButton extends StatelessWidget {
  final void Function()? onTap;
  final Color? color;
  final String? icon;
  final Color? iconColor;
  final Color? textColor;
  final Color? outlineColor;
  final String title;
  final bool disable;
  final bool loading;

  const AppButton(
      {super.key,
      required this.title,
      this.onTap,
      this.color,
      this.icon,
      this.iconColor,
      this.textColor,
      this.outlineColor,
      this.disable = false,
      this.loading = false});

  const AppButton.white(
      {super.key,
      required this.title,
      this.onTap,
      this.icon,
      this.iconColor,
      this.disable = true,
      this.loading = false})
      : color = AppColors.white,
        textColor = AppColors.black,
        outlineColor = Colors.transparent;

  const AppButton.black({
    super.key,
    required this.title,
    this.onTap,
    this.icon,
    this.iconColor,
    this.loading = false,
    this.disable = false,
  })  : color = AppColors.black,
        textColor = AppColors.white,
        outlineColor = Colors.transparent;

  const AppButton.primary({
    super.key,
    required this.title,
    this.onTap,
    this.icon,
    this.iconColor,
    this.disable = false,
    this.loading = false,
  })  : color = AppColors.primary,
        textColor = AppColors.white,
        outlineColor = Colors.transparent;

  const AppButton.grey(
      {super.key,
      required this.title,
      this.onTap,
      this.icon,
      this.iconColor,
      this.disable = false,
      this.loading = false})
      : color = AppColors.lightgrey,
        textColor = AppColors.black,
        outlineColor = Colors.transparent;

  // New outline constructor
  const AppButton.outline(
      {super.key,
      required this.title,
      this.onTap,
      this.outlineColor = AppColors.primary,
      this.textColor = AppColors.black,
      this.icon,
      this.iconColor,
      this.disable = false,
      this.loading = false})
      : color = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: TextButton(
        onPressed: disable || loading ? () {} : onTap,
        style: TextButton.styleFrom(
          backgroundColor: disable || loading ? color!.withOpacity(0.3) : color,
          iconColor: iconColor,
          side: BorderSide(color: outlineColor ?? AppColors.black, width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              SvgPicture.asset(
                icon!,
                height: 20,
                width: 20,
                // ignore: deprecated_member_use
                color: iconColor ?? Colors.black,
              ),
            if (icon != null) const SizedBox(width: 20),
            loading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: CircularProgressIndicator(color: textColor))
                : AppText.button(
                    title,
                    color: textColor,
                    centered: true,
                    fontSize: 16,
                  ),
          ],
        ),
      ),
    );
  }
}
