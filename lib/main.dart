import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/router/router.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/services/notification_service.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/firebase_options.dart';
import 'package:starter_codes/widgets/app_flushbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final rootContainer = ProviderContainer();

    // Initialize SharedPreferences and locator first
    await setupLocator();

      await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    NotificationService.instance.setProviderContainer(rootContainer);
    await NotificationService.instance.initialize();

    runApp(UncontrolledProviderScope(
      container: rootContainer,
      child: const MyApp(),
    ));
  } catch (e) {
    print('Error initializing app: $e');
    // Fallback initialization
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      useInheritedMediaQuery: true,
      minTextAdapt: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light()
            .copyWith(scaffoldBackgroundColor: Colors.grey.shade100),
        builder: (context, widget) => Navigator(
          key: AppFlushBar.navigatorKey,
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => FlushBarLayer(
              child: widget!,
            ),
          ),
        ),
        navigatorKey: NavigationService.instance.navigatorKey,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: NavigatorRoutes.splashScreen,
      ),
    );
  }
}
