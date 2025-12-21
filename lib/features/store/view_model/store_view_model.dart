import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/features/store/data/store_service.dart';
import 'package:starter_codes/features/store/model/store_response_model.dart';
import 'package:starter_codes/provider/user_provider.dart';

class StoresViewModel extends AsyncNotifier<StoreResponse> {
  String _currentSearchQuery = '';
  String? _currentTag;

  DateTime? _lastFetchedTime;
  final Duration _staleTime = const Duration(minutes: 5);

  @override
  Future<StoreResponse> build() {
    return _fetchStores(forceRefresh: true);
  }

  bool _isDataStale() {
    if (_lastFetchedTime == null) return true;
    return DateTime.now().difference(_lastFetchedTime!) > _staleTime;
  }

  Future<StoreResponse> _fetchStores({
    String? search,
    String? tags,
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final storeService = ref.read(storeServiceProvider);
    const logger = AppLogger(StoresViewModel);
    final user = ref.read(userProvider);

    final userState = user?.currentState;

    // --- Stale Data Check ---
    if (!forceRefresh && 
        !_isDataStale() && 
        state.hasValue &&
        _currentSearchQuery == (search ?? '') &&
        _currentTag == (tags ?? null)) {
      logger.i('Stores data is not stale and has data. Using cached data.');
      return state.value!;
    }

    try {
      logger.d('Fetching stores with user state: $userState, search: $search, tags: $tags, page: $page, limit: $limit, forceRefresh: $forceRefresh');
      final response = await storeService.getStores(
        state: userState,
        search: search,
        tags: tags,
        page: page,
        limit: limit,
      );
      _lastFetchedTime = DateTime.now();
      logger.d('Stores fetched successfully. Number of items: ${response.stores.length}');
      return response;
    } catch (e, st) {
      logger.e('Error fetching stores: $e\n$st');
      rethrow;
    }
  }

  Future<void> filterStoresBySearch(String query) async {
    if (_currentSearchQuery == query && state.hasValue) {
      return;
    }
    _currentSearchQuery = query;

    state = const AsyncValue.loading();
    try {
      final result = await _fetchStores(
        search: _currentSearchQuery,
        tags: _currentTag,
          forceRefresh: true,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

 
  Future<void> filterStoresByTag(String? tag) async {
    if (_currentTag == tag && state.hasValue) {
      return;
    }
    _currentTag = tag;

    state = const AsyncValue.loading();
    try {
      final result = await _fetchStores(
        search: _currentSearchQuery.isEmpty ? null : _currentSearchQuery,
        tags: _currentTag,
        forceRefresh: true,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshStores() async {
    if (!state.isLoading) {
      state = AsyncValue.loading();
    }
    try {
      final result = await _fetchStores(
        search: _currentSearchQuery.isEmpty ? null : _currentSearchQuery,
        tags: _currentTag,
        forceRefresh: true,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetchStoresIfStale({bool forceRefresh = false}) async {
    if (state.isLoading && !forceRefresh) return;
    if (!forceRefresh && !_isDataStale() && state.hasValue) {
      return;
    }

    state = const AsyncValue.loading();
    try {
      final result = await _fetchStores(
        search: _currentSearchQuery.isEmpty ? null : _currentSearchQuery,
        tags: _currentTag,
        forceRefresh: true,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMoreStores() async {
    if (state is AsyncData<StoreResponse>) {
    }
  }
}

final storesViewModelProvider = AsyncNotifierProvider<StoresViewModel, StoreResponse>(
  StoresViewModel.new,
);