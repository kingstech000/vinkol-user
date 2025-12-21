import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/store/data/store_service.dart';
import 'package:starter_codes/features/store/model/store_tag_model.dart';

// Provider for selected tag to filter stores
final selectedTagProvider = StateProvider<String?>((ref) => null);

// Provider for store tags
final storeTagsProvider = FutureProvider<List<StoreTag>>((ref) async {
  final storeService = ref.read(storeServiceProvider);
  return await storeService.getStoreTags();
});

