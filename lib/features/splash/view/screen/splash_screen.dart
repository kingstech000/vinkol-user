import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/features/splash/view_model/splash_view_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // After animation completes, call initializeApp
    Future.delayed(const Duration(seconds: 5), () async {
      await ref.read(splashViewModelProvider).initializeApp();
    });
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
