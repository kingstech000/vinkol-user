import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/store/data/store_service.dart';
import 'package:starter_codes/features/store/model/store_model.dart';

class ProductListState {
  final List<StoreProduct> products;
  final int currentPage;
  final int totalPages;
  final int totalProducts;
  final bool isLoadingMore;

  ProductListState({
    this.products = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalProducts = 0,
    this.isLoadingMore = false,
  });

  ProductListState copyWith({
    List<StoreProduct>? products,
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

class ProductListViewModel extends AsyncNotifier<ProductListState> {
  @override
  Future<ProductListState> build() async {
    final store = ref.watch(currentStoreProvider);

    if (store == null) {
      return ProductListState();
    }

    return _fetchSingleStoreAndProducts(store.id);
  }

  Future<ProductListState> _fetchSingleStoreAndProducts(String storeId) async {
    final storeService = ref.read(storeServiceProvider);
    try {
      final responseData = await storeService.getSingleStore(storeId);

      final Store store = responseData.store;

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

  Future<void> refreshProducts() async {
    final store = ref.read(currentStoreProvider);
    if (store == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSingleStoreAndProducts(store.id));
  }

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

final productListViewModelProvider =
    AsyncNotifierProvider<ProductListViewModel, ProductListState>(
  ProductListViewModel.new,
);