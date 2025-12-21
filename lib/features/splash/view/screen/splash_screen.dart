import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/core/utils/app_version_checker.dart';
import 'package:starter_codes/features/splash/view_model/splash_view_model.dart';
import 'package:starter_codes/provider/app_provider.dart';
import 'package:starter_codes/widgets/force_update_bottom_sheet.dart';

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
  }

  Future<void> _checkAppVersion() async {
    try {
      final appDetailsAsync = await ref.read(appDetailsProvider.future);
      final customerApp = appDetailsAsync.data.customerApp;
      final currentVersion = await AppVersionChecker.getCurrentVersion();
      final currentBuildNumber =
          await AppVersionChecker.getCurrentBuildNumber();

      final updateRequired = AppVersionChecker.isUpdateRequired(
        customerApp,
        currentVersion,
        currentBuildNumber,
      );

      if (updateRequired && mounted) {
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Container(
            height: 250,
            width: 250,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(ImageAsset.splash), fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
