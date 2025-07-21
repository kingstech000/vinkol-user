import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/features/store/data/store_service.dart';
import 'package:starter_codes/features/store/model/store_response_model.dart';
import 'package:starter_codes/provider/user_provider.dart';

class StoresViewModel extends AsyncNotifier<StoreResponse> {
  String _currentSearchQuery = '';
  // int _currentPage = 1; // Keep if you want to re-implement pagination later

  // --- New: Stale Time Logic ---
  DateTime? _lastFetchedTime;
  final Duration _staleTime = const Duration(minutes: 5); // Data considered stale after 5 minutes

  @override
  Future<StoreResponse> build() {
    // This will initially fetch stores based on the user's state and an empty search query.
    // We want the initial build to always fetch fresh data.
    return _fetchStores(forceRefresh: true); // Force initial fetch
  }

  /// Helper to check if data is stale
  bool _isDataStale() {
    if (_lastFetchedTime == null) return true;
    return DateTime.now().difference(_lastFetchedTime!) > _staleTime;
  }

  Future<StoreResponse> _fetchStores({
    String? search,
    int page = 1,
    int limit = 10,
    bool forceRefresh = false, // New parameter to bypass stale check
  }) async {
    final storeService = ref.read(storeServiceProvider);
    const logger = AppLogger(StoresViewModel);
    final user = ref.read(userProvider);

    final userState = user?.currentState;

    // --- Stale Data Check ---
    if (!forceRefresh && !_isDataStale() && state.hasValue) {
      logger.i('Stores data is not stale and has data. Using cached data.');
      // If data is not stale and already present, return current data without fetching
      return state.value!;
    }

    try {
      logger.d('Fetching stores with user state: $userState, search: $search, page: $page, limit: $limit, forceRefresh: $forceRefresh');
      final response = await storeService.getStores(
        state: userState,
        search: search,
        page: page,
        limit: limit,
      );
      _lastFetchedTime = DateTime.now(); // Update last fetched time on success
      logger.d('Stores fetched successfully. Number of items: ${response.stores.length}');
      return response;
    } catch (e, st) {
      logger.e('Error fetching stores: $e\n$st');
      rethrow;
    }
  }

  /// Triggers a re-fetch of stores based on the current user's state and the provided search query.
  /// This will always trigger a fetch if the query changes.
  Future<void> filterStoresBySearch(String query) async {
    // Only fetch if the query has actually changed to avoid unnecessary API calls
    if (_currentSearchQuery == query && state.hasValue) {
      return; // If query same and data is already there, do nothing.
    }
    _currentSearchQuery = query; // Update the internal search query state

    state = const AsyncValue.loading(); // Set state to loading
    try {
      final result = await _fetchStores(
        search: _currentSearchQuery,
        forceRefresh: true, // Always force a refresh when filter changes
      );
      state = AsyncValue.data(result); // Update state with new data
    } catch (e, st) {
      state = AsyncValue.error(e, st); // Update state with error
    }
  }

  /// Refreshes the store list without changing filters (e.g., pull-to-refresh).
  /// This will always force a refresh, bypassing stale time.
  Future<void> refreshStores() async {
    // Only set loading if current state is not loading, to avoid flashing loading UI
    // if a background refresh is already happening (e.g., from stale time).
    if (!state.isLoading) {
      state = AsyncValue.loading();
    }
    try {
      final result = await _fetchStores(
        search: _currentSearchQuery,
        forceRefresh: true, // Always force a refresh for pull-to-refresh
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Fetches stores if they are stale or forced.
  /// Useful for initial load or when returning to screen.
  Future<void> fetchStoresIfStale({bool forceRefresh = false}) async {
    // If currently loading, or data is fresh and not forced, do nothing.
    if (state.isLoading && !forceRefresh) return;
    if (!forceRefresh && !_isDataStale() && state.hasValue) {
        final logger = AppLogger(StoresViewModel);
        logger.i('Stores data is not stale and has data. Using cached data.');
        return;
    }

    state = const AsyncValue.loading(); // Set to loading while fetching
    try {
      final result = await _fetchStores(
        search: _currentSearchQuery,
        forceRefresh: true, // Force the network call for this explicit fetch
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // loadMoreStores method is for pagination, which is a separate concern.
  // No changes needed here for stale data / refresh.
  Future<void> loadMoreStores() async {
    if (state is AsyncData<StoreResponse>) {
      // Implement pagination logic here if your API supports it.
      // E.g., check if current.totalItems > current.items.length
    }
  }
}

final storesViewModelProvider = AsyncNotifierProvider<StoresViewModel, StoreResponse>(
  StoresViewModel.new,
);