import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/data/local/local_cache_impl.dart';
import 'package:starter_codes/widgets/app_flushbar.dart';

GetIt locator = GetIt.instance;
Future<void> setupLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton(sharedPreferences);

  locator.registerLazySingleton<LocalCache>(
    () => LocalCacheImpl(
      sharedPreferences: sharedPreferences,
    ),
  );

  locator.registerLazySingleton<AppFlushBar>(
    () => AppFlushBar(),
  );
}
