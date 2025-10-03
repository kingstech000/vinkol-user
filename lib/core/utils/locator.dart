import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/data/local/local_cache_impl.dart';
import 'package:starter_codes/widgets/app_flushbar.dart';

GetIt locator = GetIt.instance;
Future<void> setupLocator() async {
  try {
    // Initialize SharedPreferences with proper error handling for iOS
    final sharedPreferences = await SharedPreferences.getInstance();

    // Verify that SharedPreferences is working by testing a simple operation
    await sharedPreferences.setBool('_test_key', true);
    final testResult = sharedPreferences.getBool('_test_key');
    await sharedPreferences.remove('_test_key');

    if (testResult != true) {
      throw Exception('SharedPreferences initialization failed on iOS');
    }

    locator.registerSingleton(sharedPreferences);

    locator.registerLazySingleton<LocalCache>(
      () => LocalCacheImpl(
        sharedPreferences: sharedPreferences,
      ),
    );

    locator.registerLazySingleton<AppFlushBar>(
      () => AppFlushBar(),
    );
  } catch (e) {
    print('Error setting up locator: $e');
    rethrow;
  }
}
