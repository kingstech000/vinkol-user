import 'package:flutter/material.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/widgets/gap.dart';

class MiniActionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final IconData? icon;

  final String action;
  final String? title;
  final VoidCallback? actionOnTap;

  const MiniActionAppBar({
    super.key,
    this.icon = Icons.arrow_back_ios,
    this.title,
    required this.action,
    this.actionOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: icon != null
          ? GestureDetector(
              onTap: () {
                NavigationService.instance.goBack();
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                child: Row(
                  children: [
                    Gap.w20,
                    Icon(
                      icon,
                      // color: Theme.of(context).colorScheme.inversePrimary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            )
          : null,
      title: AppText.h4(
        title ?? '',
        // fontSize: 20,
      ),
      actions: [
        GestureDetector(
          onTap: actionOnTap,
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(30),
            ),
            child: AppText.button(
              action,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
      leadingWidth: 100.h,
      elevation: 0, // Remove shadow by default
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}
