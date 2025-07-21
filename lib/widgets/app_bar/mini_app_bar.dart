import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/gap.dart';

class MiniAppBar extends StatelessWidget implements PreferredSizeWidget {
  MiniAppBar({
    super.key,
    this.color = Colors.black,
    this.icon = Icons.arrow_back_ios,
    this.actions,
    this.title = '',
    this.leading = true,
  });
  final Color color;
  final IconData icon;
  final String? title;
  final bool leading;
  final List<Widget>? actions;

  final NavigationService _navigationService = NavigationService.instance;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: leading
          ? GestureDetector(
              onTap: () {
                _navigationService.goBack();
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                child: Row(
                  children: [
                    Gap.w20,
                    Icon(
                      icon,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ],
                ),
              ),
            )
          : null,
      centerTitle: true,
      automaticallyImplyLeading: leading,
      title: AppText.button(
        title ?? '', color: Colors.black54,
        // fontSize: 20,
      ),
      actions: actions,
      leadingWidth: 100.h,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}
