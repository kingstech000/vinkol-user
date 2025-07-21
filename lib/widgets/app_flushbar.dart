// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/models/failure.dart';

class AppFlushBar {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late final BuildContext context;

  init(BuildContext context) {
    this.context = context;
  }

  void showFailure({
    // required BuildContext context,
    required Failure failure,
    String? title,
    bool showTitle = true,
    Color? color,
    Duration? duration,
    FlushbarPosition position = FlushbarPosition.BOTTOM,
  }) {
    Flushbar<dynamic>(
      flushbarPosition: position,
      duration: duration ?? const Duration(seconds: 5),
      backgroundColor: color ?? AppColors.red,
      margin: const EdgeInsets.all(2),
      borderRadius: BorderRadius.circular(8),
      message: failure.message,
      title: showTitle ? title ?? failure.title : null,
    ).show(navigatorKey.currentContext!);
  }

  /// show success indication
  void showSuccess({
    //required BuildContext context,
    required String message,
    String? title,
    Color? color,
    Duration? duration,
  }) {
    Flushbar<dynamic>(
      flushbarPosition: FlushbarPosition.TOP,
      duration: duration ?? const Duration(seconds: 5),
      backgroundColor: color ?? AppColors.primary,
      margin: const EdgeInsets.all(2),
      borderRadius: BorderRadius.circular(8),
      // backgroundGradient: LinearGradient(
      //   colors: [
      //     Colors.green.shade800,
      //     Colors.greenAccent.shade700,
      //     AppColors.primaryColor.,
      //   ],
      //   // stops: [0.6, 1],
      // ),
      message: message,
      title: title,
    ).show(navigatorKey.currentContext!);
  }

  void showGeneric({
    //required BuildContext context,
    required String message,
    String? title,
    Color? color,
    Duration? duration,
  }) {
    Flushbar<dynamic>(
      flushbarPosition: FlushbarPosition.TOP,
      duration: duration ?? const Duration(seconds: 5),
      backgroundColor: color ?? AppColors.primary,
      icon: Icon(
        Icons.info_outline,
        size: 28,
        color: Colors.grey.shade100,
      ),
      // leftBarIndicatorColor: Colors.grey.shade100,
      shouldIconPulse: false,
      // backgroundGradient: LinearGradient(
      //   colors: [
      //     Colors.green.shade800,
      //     Colors.greenAccent.shade700,
      //     AppColors.primaryColor.shade900,
      //   ],
      //   // stops: [0.6, 1],
      // ),
      boxShadows: const [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(8),
      message: message,
      title: title,
    ).show(navigatorKey.currentContext!);
  }

  void showNotification({
    //required BuildContext context,
    required String body,
    String? title,
    Color? color,
    Duration? duration,
  }) {
    Flushbar<dynamic>(
      flushbarPosition: FlushbarPosition.TOP,
      duration: duration ?? const Duration(seconds: 5),
      backgroundColor: color ?? AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      icon: Icon(
        Icons.notifications_active,
        size: 28,
        color: Colors.grey.shade100,
      ),
      // leftBarIndicatorColor: Colors.grey.shade100,
      shouldIconPulse: false,
      // backgroundGradient: LinearGradient(
      //   colors: [
      //     Colors.green.shade800,
      //     Colors.greenAccent.shade700,
      //     AppColors.primaryColor.shade900,
      //   ],
      //   // stops: [0.6, 1],
      // ),
      boxShadows: const [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      margin: const EdgeInsets.all(12),
      message: body,
      title: title,
      messageColor: Colors.white,
      titleColor: Colors.white,
    ).show(navigatorKey.currentContext!);
  }
}

class FlushBarLayer extends StatefulWidget {
  const FlushBarLayer({super.key, required this.child});

  final Widget child;

  @override
  State<FlushBarLayer> createState() => _FlushBarLayerState();
}

class _FlushBarLayerState extends State<FlushBarLayer> {
  @override
  void initState() {
    locator<AppFlushBar>().init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
