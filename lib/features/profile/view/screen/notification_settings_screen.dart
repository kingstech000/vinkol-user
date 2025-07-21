// lib/features/profile/view/screens/notification_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationSettingScreen> {
  bool _generalNotificationEnabled = true;
  bool _emailNotificationEnabled = true;
  bool _soundAndVibrateEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiniAppBar(
        title: 'Notification',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap.h24,
            _NotificationToggle(
              title: 'General notification',
              value: _generalNotificationEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _generalNotificationEnabled = newValue;
                });
              },
            ),
            _NotificationToggle(
              title: 'Email notification',
              value: _emailNotificationEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _emailNotificationEnabled = newValue;
                });
              },
            ),
            _NotificationToggle(
              title: 'Sound & Vibrate',
              value: _soundAndVibrateEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _soundAndVibrateEnabled = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggle({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.body(title, color: AppColors.black),
          Transform.scale(
            // Scale the switch for a smaller visual
            scale: 0.8,
            child: CupertinoSwitch(
              // Use CupertinoSwitch for the iOS look
              value: value,
              onChanged: onChanged,
              activeTrackColor:
                  AppColors.primary, // Your primary color for active state
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}
