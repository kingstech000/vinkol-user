import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/store/data/store_service.dart';
import 'package:starter_codes/features/store/model/store_model.dart'; // Ensure Store model is imported

// Define the state for the product list
class ProductListState {
  final List<StoreProduct> products; // Changed to StoreProduct
  final int currentPage;
  final int totalPages;
  final int totalProducts;
  final bool isLoadingMore; // To indicate if more items are being loaded at the bottom

  ProductListState({
    this.products = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalProducts = 0,
    this.isLoadingMore = false,
  });

  ProductListState copyWith({
    List<StoreProduct>? products, // Changed to StoreProduct
    int? currentPage,
    int? totalPages,
    int? totalProducts,
    bool? isLoadingMore,
  }) {
    return ProductListState(
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalProducts: totalProducts ?? this.totalProducts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// 2. ProductListViewModel (AsyncNotifier)
class ProductListViewModel extends AsyncNotifier<ProductListState> {
  @override
  Future<ProductListState> build() async {
    final store = ref.watch(currentStoreProvider);

    if (store == null) {
      return ProductListState();
    }

    return _fetchSingleStoreAndProducts(store.id);
  }

  // Private helper to fetch store and its products from the API using getSingleStore
  Future<ProductListState> _fetchSingleStoreAndProducts(String storeId) async {
    final storeService = ref.read(storeServiceProvider);
    try {
      final responseData = await storeService.getSingleStore(storeId);

      final Store store = responseData.store;

      // Products are directly StoreProduct objects now
      final List<StoreProduct> newProducts = responseData.storeProducts ?? [];

      return ProductListState(
        products: newProducts,
        currentPage: 1,
        totalPages: 1,
        totalProducts: newProducts.length,
        isLoadingMore: false,
      );
    } catch (e, _) {
      rethrow;
    }
  }

  // Method to refresh products (e.g., for pull-to-refresh)
  Future<void> refreshProducts() async {
    final store = ref.read(currentStoreProvider);
    if (store == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSingleStoreAndProducts(store.id));
  }

  // If getSingleStore fetches ALL products, loadMoreProducts will simply re-fetch.
  Future<void> loadMoreProducts() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || currentState.currentPage >= currentState.totalPages) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    final store = ref.read(currentStoreProvider);
    if (store == null) return;

    state = await AsyncValue.guard(() async {
      final newState = await _fetchSingleStoreAndProducts(store.id);
      return newState.copyWith(isLoadingMore: false);
    });
  }
}

// Provider for ProductListViewModel
final productListViewModelProvider =
    AsyncNotifierProvider<ProductListViewModel, ProductListState>(
  ProductListViewModel.new,
);