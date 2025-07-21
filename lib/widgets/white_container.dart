import 'package:flutter/material.dart';
import 'package:starter_codes/core/utils/colors.dart';

class WhiteContainer extends StatelessWidget {
  const WhiteContainer({super.key, required this.widget});
  final Widget widget;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: AppColors.white),
      child: widget,
    );
  }
}
