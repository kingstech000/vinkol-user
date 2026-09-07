import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/design/vinkol_theme.dart';
import 'package:starter_codes/core/market/locale_provider.dart';
import 'package:starter_codes/core/market/market_provider.dart';
import 'package:starter_codes/core/router/router.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/services/notification_service.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/firebase_options.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/app_flushbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final rootContainer = ProviderContainer();

    await setupLocator();

    // Resolve the market before the first frame. Every money string in the app reads the
    // active market ambiently, so this has to settle before anything renders. Falls back to
    // Nigeria — the live market — on a cold install.
    await resolveMarketAtStartup();

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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Locale is market-owned: Nigeria ships English, Canada ships English and Français.
    final locale = ref.watch(appLocaleProvider);
    final supportedLocales = ref.watch(supportedLocalesProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      useInheritedMediaQuery: true,
      minTextAdapt: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: VinkolTheme.light(),
        darkTheme: VinkolTheme.dark(),
        // Midnight is dark-first (D-07), but the feature screens still paint from the
        // light-only AppColors shim, so a device in dark mode would render unreadable
        // screens. Pinned to light until the screens migrate to `context.vinkol`; flip to
        // ThemeMode.system — then to dark as the default — as WP2 onward lands.
        themeMode: ThemeMode.light,
        locale: locale,
        supportedLocales: supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
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
