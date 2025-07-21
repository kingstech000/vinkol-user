import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/product_card.dart';
import 'package:starter_codes/features/store/view_model/product_list_view_model.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/empty_content.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/dot_spinning_indicator.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      ref.read(productListViewModelProvider.notifier).loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(currentStoreProvider);
    final productListAsyncValue = ref.watch(productListViewModelProvider);

    final totalItemsInCart = ref.watch(cartProvider.select((cartItems) {
      return cartItems.products.fold(0, (sum, item) => sum + (item.quantity ?? 0));
    }));

    if (store == null) {
      return Scaffold(
        appBar: MiniAppBar(),
        body: const Center(child: Text('No store selected. Please go back and select a store.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: MiniAppBar(
        title: store.name,
      ),
      body: Stack(
        children: [
          productListAsyncValue.when(
            data: (productListState) {
              final products = productListState.products;

              if (products.isEmpty && !productListState.isLoadingMore) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref.read(productListViewModelProvider.notifier).refreshProducts(),
                  child: const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 200,
                      child:const Center(
                    child: EmptyContent(
                      contentText: 'No Product Available in this store yet.',
                    icon:Icons.production_quantity_limits,
                    ),
                  )
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => ref.read(productListViewModelProvider.notifier).refreshProducts(),
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    // *** KEY CHANGE HERE ***
                    // Adjust this value to make cards taller relative to their width.
                    // A smaller value means taller cards.
                    childAspectRatio: 0.6, // Or even 0.55 if content is still overflowing
                  ),
                  itemCount: products.length + (productListState.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == products.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      );
                    }
                    final product = products[index];
                    return ProductCard(
                      product: product,
                    );
                  },
                ),
              );
            },
            loading: () => const Center(
              child: DotSpinningIndicator(color: AppColors.primary),
            ),
            error: (error, stack) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(error.toString()),
                    Gap.h16,
                    ElevatedButton(
                      onPressed: () {
                        ref.read(productListViewModelProvider.notifier).refreshProducts();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildAddedToCartButton(totalItemsInCart),
          ),
        ],
      ),
    );
  }

  Widget _buildAddedToCartButton(int totalItemsInCart) {
    if (totalItemsInCart == 0) {
      return const SizedBox.shrink();
    }

    return AppButton(
      title: '($totalItemsInCart) Added to Cart',
      color: AppColors.black,
      textColor: AppColors.white,
      onTap: () {
        NavigationService.instance.navigateTo(NavigatorRoutes.cartScreen);
      },
    );
  }
}