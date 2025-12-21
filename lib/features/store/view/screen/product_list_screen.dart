import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/product_card.dart';
import 'package:starter_codes/features/store/view_model/product_list_view_model.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/dot_spinning_indicator.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchVisible = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(productListViewModelProvider.notifier).loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _searchQuery = '';
        _searchFocusNode.unfocus();
      } else {
        // Focus the search field when it becomes visible
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _searchFocusNode.requestFocus();
          }
        });
      }
    });
  }

  List<StoreProduct> _filterProducts(List<StoreProduct> products) {
    if (_searchQuery.isEmpty) {
      return products;
    }
    return products.where((product) {
      final title = product.title.toLowerCase();
      final category = product.category.toLowerCase();
      final description = (product.description ?? '').toLowerCase();
      return title.contains(_searchQuery) ||
          category.contains(_searchQuery) ||
          description.contains(_searchQuery);
    }).toList();
  }

  // Responsive grid configuration
  SliverGridDelegateWithFixedCrossAxisCount _getResponsiveGridDelegate() {
    final screenWidth = MediaQuery.of(context).size.width;

    // For very small screens (less than 320px width)
    if (screenWidth < 320) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.65, // Much longer cards for single column
      );
    }
    // For small screens (320px - 480px width)
    else if (screenWidth < 480) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio:
            0.6, // Much longer cards for better content visibility
      );
    }
    // For medium screens (480px - 768px width)
    else if (screenWidth < 768) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.65, // Longer cards for medium screens
      );
    }
    // For large screens (768px and above)
    else {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15.0,
        mainAxisSpacing: 15.0,
        childAspectRatio: 0.7, // Longer cards for large screens
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(currentStoreProvider);
    final productListAsyncValue = ref.watch(productListViewModelProvider);

    final totalItemsInCart = ref.watch(cartProvider.select((cartItems) {
      return cartItems.products
          .fold(0, (sum, item) => sum + (item.quantity ?? 0));
    }));

    if (store == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: MiniAppBar(),
        body: _buildNoStoreSelected(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.only(left: 16.w, top: 16.w),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primary,
                        size: 20.w,
                      ),
                    ),
                  ),
                  _buildStoreHeader(store),
                  // Search Field

                  Expanded(
                    child: productListAsyncValue.when(
                      data: (productListState) {
                        final allProducts = productListState.products;
                        final filteredProducts = _filterProducts(allProducts);

                        if (filteredProducts.isEmpty &&
                            !productListState.isLoadingMore &&
                            _searchQuery.isNotEmpty) {
                          return RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () => ref
                                .read(productListViewModelProvider.notifier)
                                .refreshProducts(),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: _buildNoSearchResults(),
                              ),
                            ),
                          );
                        }

                        if (allProducts.isEmpty &&
                            !productListState.isLoadingMore) {
                          return RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () => ref
                                .read(productListViewModelProvider.notifier)
                                .refreshProducts(),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: _buildEmptyState(),
                              ),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () => ref
                              .read(productListViewModelProvider.notifier)
                              .refreshProducts(),
                          child: Column(
                            children: [
                              // Products Header
                              _buildProductsHeader(
                                _searchQuery.isNotEmpty
                                    ? filteredProducts.length
                                    : allProducts.length,
                              ),

                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                height: _isSearchVisible ? null : 0,
                                child: _isSearchVisible
                                    ? _buildSearchField()
                                    : const SizedBox.shrink(),
                              ),

                              // Products Grid
                              Expanded(
                                child: GridView.builder(
                                  controller: _scrollController,
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width < 320
                                          ? 8.0
                                          : 16.0),
                                  gridDelegate: _getResponsiveGridDelegate(),
                                  itemCount: filteredProducts.length +
                                      (productListState.isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == filteredProducts.length) {
                                      return _buildLoadMoreIndicator();
                                    }
                                    final product = filteredProducts[index];
                                    return ProductCard(
                                      product: product,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => _buildLoadingState(),
                      error: (error, stack) => _buildErrorState(error),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: _buildFloatingCartButton(totalItemsInCart),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoStoreSelected() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange[100]!,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.store_outlined,
                color: Colors.orange[400],
                size: 50.w,
              ),
            ),
            Gap.h24,
            AppText.h3(
              'No Store Selected',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              centered: true,
            ),
            Gap.h8,
            AppText.body(
              'Please go back and select a store to\nview available products',
              fontSize: 14,
              color: Colors.grey[600],
              centered: true,
              height: 1.5,
            ),
            Gap.h24,
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader(Store store) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (store.avatar?.imageUrl != null)
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange[200]!,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: store.avatar!.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(
                    Icons.store_rounded,
                    color: Colors.orange[400],
                    size: 24.w,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange[200]!,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.store_rounded,
                color: Colors.orange[400],
                size: 24.w,
              ),
            ),
          Gap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h3(
                  store.name ?? "Store",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                Gap.h4,
                AppText.caption(
                  'Available for delivery',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          // Search Icon Button

          // Store Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: store.isOpen ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: store.isOpen ? Colors.green[500] : Colors.red[500],
                    shape: BoxShape.circle,
                  ),
                ),
                Gap.w6,
                AppText.caption(
                  store.isOpen ? 'Open' : 'Closed',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: store.isOpen ? Colors.green[700] : Colors.red[700],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Focus(
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[600],
              size: 20.w,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[600],
                      size: 20.w,
                    ),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: Colors.grey[400],
                size: 50.w,
              ),
            ),
            Gap.h24,
            AppText.h3(
              'No Products Found',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              centered: true,
            ),
            Gap.h8,
            AppText.body(
              'No products match your search "$_searchQuery"\nTry a different search term',
              fontSize: 14,
              color: Colors.grey[600],
              centered: true,
              height: 1.5,
            ),
            Gap.h24,
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
              },
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsHeader(int productCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: AppColors.primary,
              size: 20.w,
            ),
          ),
          Gap.w12,
          AppText.h4(
            '$productCount product${productCount != 1 ? 's' : ''} available',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: InkWell(
              onTap: () {
                _toggleSearch();
              },
              child: Icon(
                Icons.search,
                color: AppColors.primary,
                size: 20.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const DotSpinningIndicator(color: AppColors.primary),
          Gap.h16,
          AppText.body(
            'Loading products...',
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: Colors.grey[400],
                size: 50.w,
              ),
            ),
            Gap.h24,
            AppText.h3(
              'No Products Available',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              centered: true,
            ),
            Gap.h8,
            AppText.body(
              'This store doesn\'t have any products\navailable at the moment',
              fontSize: 14,
              color: Colors.grey[600],
              centered: true,
            ),
            Gap.h24,
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(productListViewModelProvider.notifier)
                    .refreshProducts();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red[100]!,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red[400],
                size: 50.w,
              ),
            ),
            Gap.h24,
            AppText.h3(
              'Failed to Load Products',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              centered: true,
            ),
            Gap.h8,
            AppText.body(
              'Unable to fetch products from the store.\nPlease check your connection and try again.',
              fontSize: 14,
              color: Colors.grey[600],
              centered: true,
              height: 1.5,
            ),
            Gap.h24,
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(productListViewModelProvider.notifier)
                      .refreshProducts();
                },
                icon: const Icon(
                  Icons.refresh,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
            Gap.h8,
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCartButton(int totalItemsInCart) {
    if (totalItemsInCart == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black87,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            NavigationService.instance.navigateTo(
              NavigatorRoutes.cartScreen,
              argument: {
                'isFromWebviewClosing': false,
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$totalItemsInCart item${totalItemsInCart != 1 ? 's' : ''} in cart',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Tap to view cart',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
