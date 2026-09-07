import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/utils/app_version_checker.dart';
import 'package:starter_codes/features/splash/view_model/splash_view_model.dart';
import 'package:starter_codes/provider/app_provider.dart';
import 'package:starter_codes/widgets/force_update_bottom_sheet.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_mark.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppVersion();
    _proceedWithInitialization();
  }

  Future<void> _checkAppVersion() async {
    try {
      final appDetailsAsync = await ref.read(appDetailsProvider.future);
      final isAndroid = Platform.isAndroid;
      final platformDetails =
          appDetailsAsync.data.getPlatformDetails(isAndroid);
      final customerApp = platformDetails.customerApp;
      final currentVersion = await AppVersionChecker.getCurrentVersion();
      final currentBuildNumber =
          await AppVersionChecker.getCurrentBuildNumber();

      final updateRequired = AppVersionChecker.isUpdateRequired(
        customerApp,
        currentVersion,
        currentBuildNumber,
      );

      if (updateRequired) {
        ForceUpdateBottomSheet.show(context);
      } else {
        _proceedWithInitialization();
      }
    } catch (e) {
      _proceedWithInitialization();
    }
  }

  void _proceedWithInitialization() {
    if (mounted) {
      Future.delayed(const Duration(seconds: 5), () async {
        if (mounted) {
          await ref.read(splashViewModelProvider).initializeApp();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: v.canvas,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      VinkolMark(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  VinkolSpace.pageMargin,
                  0,
                  VinkolSpace.pageMargin,
                  VinkolSpace.huge2,
                ),
                child: Text(
                  'LOGISTICS, EVERYWHERE',
                  style: VinkolType.labelS.copyWith(color: v.textTertiary),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
