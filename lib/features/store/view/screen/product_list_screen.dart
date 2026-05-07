import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _ProductListScreenState extends ConsumerState<ProductListScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchVisible = false;
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
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
    _animationController.dispose();
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

  SliverGridDelegateWithFixedCrossAxisCount _getResponsiveGridDelegate() {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 320) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.65,
      );
    } else if (screenWidth < 480) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.6,
      );
    } else if (screenWidth < 768) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.65,
      );
    } else {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15.0,
        mainAxisSpacing: 15.0,
        childAspectRatio: 0.7,
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
      backgroundColor: Colors.grey[50],
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern App Bar with Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          AppColors.primary.withOpacity(0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Back Button Row
                        Padding(
                          padding: EdgeInsets.only(
                              left: 16.w, top: 16.h, right: 16.w),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    color: AppColors.primary,
                                    size: 18.w,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Search Toggle Button
                              InkWell(
                                onTap: _toggleSearch,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: _isSearchVisible
                                        ? AppColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _isSearchVisible
                                            ? AppColors.primary.withOpacity(0.3)
                                            : Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isSearchVisible
                                        ? Icons.close
                                        : Icons.search,
                                    color: _isSearchVisible
                                        ? Colors.white
                                        : AppColors.primary,
                                    size: 20.w,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap.h16,
                        _buildStoreHeader(store),
                      ],
                    ),
                  ),

                  // Search Field Animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _isSearchVisible ? null : 0,
                    child: _isSearchVisible
                        ? _buildSearchField()
                        : const SizedBox.shrink(),
                  ),

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
                              child: SizedBox(
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
                              child: SizedBox(
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
                              _buildProductsHeader(
                                  _searchQuery.isNotEmpty
                                      ? filteredProducts.length
                                      : allProducts.length,
                                  store),
                              Expanded(
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: GridView.builder(
                                      controller: _scrollController,
                                      padding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width <
                                                  320
                                              ? 8.0
                                              : 16.0),
                                      gridDelegate:
                                          _getResponsiveGridDelegate(),
                                      itemCount: filteredProducts.length +
                                          (productListState.isLoadingMore
                                              ? 1
                                              : 0),
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
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange[100]!,
                    Colors.orange[50]!,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.store_outlined,
                color: Colors.orange[600],
                size: 60.w,
              ),
            ),
            Gap.h32,
            AppText.h3(
              'No Store Selected',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              centered: true,
            ),
            Gap.h12,
            AppText.body(
              'Please select a store to view\navailable products',
              fontSize: 15,
              color: Colors.grey[600],
              centered: true,
              height: 1.6,
            ),
            Gap.h32,
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8)
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon:
                    const Icon(Icons.arrow_back, size: 20, color: Colors.white),
                label: const Text(
                  'Go Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
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
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16.h),
      child: Row(
        children: [
          // Store Avatar with Gradient Border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[400]!, Colors.orange[600]!],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: store.avatar?.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: store.avatar!.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Icon(
                          Icons.store_rounded,
                          color: Colors.orange[400],
                          size: 28.w,
                        ),
                      )
                    : Icon(
                        Icons.store_rounded,
                        color: Colors.orange[400],
                        size: 28.w,
                      ),
              ),
            ),
          ),
          Gap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText.h3(
                        store.name ?? "Store",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Gap.h6,
                if (store.address != null)
                  Row(
                    children: [
                      // Container(
                      //   padding: EdgeInsets.all(4.w),
                      //   decoration: BoxDecoration(
                      //     color: AppColors.primary.withOpacity(0.1),
                      //     shape: BoxShape.circle,
                      //   ),
                      //   child: Icon(
                      //     Icons.location_on,
                      //     size: 12.w,
                      //     color: AppColors.primary,
                      //   ),
                      // ),
                      // Gap.w6,
                      Expanded(
                        child: AppText.h4(
                          store.address!,
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search for products...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14.sp,
          ),
          prefixIcon: Container(
            padding: EdgeInsets.all(12.w),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 22.w,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[700],
                      size: 16.w,
                    ),
                  ),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[200]!, Colors.grey[100]!],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: Colors.grey[400],
                size: 60.w,
              ),
            ),
            Gap.h32,
            AppText.h3(
              'No Products Found',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              centered: true,
            ),
            Gap.h12,
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'No products match '),
                  TextSpan(
                    text: '"$_searchQuery"',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const TextSpan(text: '\nTry a different search term'),
                ],
              ),
            ),
            Gap.h32,
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8)
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _searchController.clear(),
                icon: const Icon(Icons.clear, size: 20, color: Colors.white),
                label: const Text(
                  'Clear Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsHeader(int productCount, Store store) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 20.w,
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.body(
                  'Available Products',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                Gap.h2,
                AppText.h4(
                  '$productCount Product${productCount != 1 ? 's' : ''}',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
          Gap.w8,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: store.isOpen
                  ? LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                    )
                  : LinearGradient(
                      colors: [Colors.red[400]!, Colors.red[600]!],
                    ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: (store.isOpen ? Colors.green : Colors.red)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Gap.w6,
                AppText.caption(
                  store.isOpen ? 'Open' : 'Closed',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ],
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
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const DotSpinningIndicator(color: AppColors.primary),
          ),
          Gap.h24,
          AppText.body(
            'Loading products...',
            fontSize: 15,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
          Gap.h8,
          AppText.caption(
            'Please wait',
            fontSize: 13,
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[200]!, Colors.grey[100]!],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: Colors.grey[400],
                size: 60.w,
              ),
            ),
            Gap.h32,
            AppText.h3(
              'No Products Available',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              centered: true,
            ),
            Gap.h12,
            AppText.body(
              'This store doesn\'t have any products\navailable at the moment',
              fontSize: 15,
              color: Colors.grey[600],
              centered: true,
              height: 1.6,
            ),
            Gap.h32,
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8)
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(productListViewModelProvider.notifier)
                      .refreshProducts();
                },
                icon: const Icon(Icons.refresh, size: 20, color: Colors.white),
                label: const Text(
                  'Refresh',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
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
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[100]!, Colors.red[50]!],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red[400],
                size: 60.w,
              ),
            ),
            Gap.h32,
            AppText.h3(
              'Failed to Load Products',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              centered: true,
            ),
            Gap.h12,
            AppText.body(
              'Unable to fetch products from the store.\nPlease check your connection and try again.',
              fontSize: 15,
              color: Colors.grey[600],
              centered: true,
              height: 1.6,
            ),
            Gap.h32,
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8)
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(productListViewModelProvider.notifier)
                      .refreshProducts();
                },
                icon: const Icon(Icons.refresh, size: 20, color: Colors.white),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
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
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
            Gap.h12,
            const Text(
              'Loading more...',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
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

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  HapticFeedback.lightImpact();
                  NavigationService.instance.navigateTo(
                    NavigatorRoutes.cartScreen,
                    argument: {'isFromWebviewClosing': false},
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      Gap.w16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$totalItemsInCart item${totalItemsInCart != 1 ? 's' : ''}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Gap.h2,
                            Text(
                              'View Cart',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
