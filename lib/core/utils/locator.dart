import 'package:get_it/get_it.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/data/local/local_cache_impl.dart';
import 'package:starter_codes/widgets/app_flushbar.dart';
import 'package:starter_codes/core/services/dialog_service.dart';

GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  try {
    print('🚀 Setting up locator with Hive...');

    // Create and initialize LocalCache
    final localCache = LocalCacheImpl();
    await localCache.initialize(); // ✅ This initializes Hive

    // Register as singleton
    locator.registerSingleton<LocalCache>(localCache);

    locator.registerLazySingleton<AppFlushBar>(
      () => AppFlushBar(),
    );

    locator.registerLazySingleton<DialogService>(
      () => DialogService(),
    );

    print('✅ Locator setup complete');
  } catch (e) {
    print('❌ Error setting up locator: $e');
    rethrow;
  }
}
