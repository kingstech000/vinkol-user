
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/gap.dart';

class EmptyContent extends StatelessWidget {
  const EmptyContent({
    super.key,
    this.contentText = '',
    this.icon = Icons.inbox,
  });
  final String contentText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Option 1: Using CircleAvatar (recommended for simplicity)
          CircleAvatar(
            radius: 60.r, // Adjust radius as needed
            backgroundColor: AppColors.primary.withOpacity(0.1), // Light background color
            child: Icon(
              icon,
              size: 80.r, // Icon size should be smaller than radius
              color: AppColors.primary,
            ),
          ),

          // Option 2: Using ClipOval (if you need more custom control over the icon background)
          // ClipOval(
          //   child: Container(
          //     padding: EdgeInsets.all(10.r), // Padding around the icon
          //     decoration: BoxDecoration(
          //       color: AppColors.primary.withOpacity(0.1), // Light background color
          //       shape: BoxShape.circle,
          //     ),
          //     child: Icon(
          //       icon,
          //       size: 30.r,
          //       color: AppColors.primary,
          //     ),
          //   ),
          // ),

          Gap.h10,
          AppText.caption(
            contentText,
            fontSize: 14,
            centered: true,
            color: AppColors.primary,
          )
        ],
      ),
    );
  }
}