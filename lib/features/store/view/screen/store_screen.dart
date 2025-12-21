import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/store_card.dart';
import 'package:starter_codes/features/store/view_model/store_view_model.dart';
import 'package:starter_codes/provider/store_provider.dart';
import 'package:starter_codes/widgets/dot_spinning_indicator.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'dart:async'; // For Timer

class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({super.key});

  @override
  ConsumerState<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends ConsumerState<StoresScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _previousTag;

  @override
  void initState() {
    super.initState();
    // Initial fetch of stores when the screen is first loaded.
    // The ViewModel's stale time logic will determine if a network call is needed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if a tag is selected
      final selectedTag = ref.read(selectedTagProvider);
      if (selectedTag != null) {
        ref
            .read(storesViewModelProvider.notifier)
            .filterStoresByTag(selectedTag);
        // Clear the selected tag after using it
        ref.read(selectedTagProvider.notifier).state = null;
      } else {
        ref.read(storesViewModelProvider.notifier).fetchStoresIfStale();
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref
          .read(storesViewModelProvider.notifier)
          .filterStoresBySearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Responsive grid configuration
  SliverGridDelegateWithFixedCrossAxisCount _getResponsiveGridDelegate() {
    final screenWidth = MediaQuery.of(context).size.width;

    // For very small screens (less than 320px width)
    if (screenWidth < 320) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      );
    }
    // For small screens (320px - 480px width)
    else if (screenWidth < 480) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.9,
      );
    }
    // For medium screens (480px - 768px width)
    else if (screenWidth < 768) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      );
    }
    // For large screens (768px and above)
    else {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storesAsyncValue = ref.watch(storesViewModelProvider);
    final selectedTag = ref.watch(selectedTagProvider);

    if (selectedTag != null && selectedTag != _previousTag) {
      _previousTag = selectedTag;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(storesViewModelProvider.notifier)
            .filterStoresByTag(selectedTag);
        ref.read(selectedTagProvider.notifier).state = null;
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 20, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      NavigationService.instance.goBack();
                    },
                    child: Icon(Icons.arrow_back_ios_new,
                        color: AppColors.primary, size: 20.w),
                  ),
                  Gap.h16,
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 20.w,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.h1(
                              'Stores Around You',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                            Text(
                              'Find nearby stores and shops',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Gap.h20,

                  // Enhanced Search Bar
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for stores, shops, markets...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          child: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              width: .5, color: AppColors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              width: .5, color: AppColors.black),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Expanded(
              child: storesAsyncValue.when(
                data: (storeResponse) {
                  _previousTag = null;
                  final List<Store> stores = storeResponse.stores;
                  if (stores.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => ref
                          .read(storesViewModelProvider.notifier)
                          .refreshStores(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: _buildEmptyState(),
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => ref
                        .read(storesViewModelProvider.notifier)
                        .refreshStores(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Results header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${stores.length} store${stores.length != 1 ? 's' : ''} found',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),

                          Gap.h16,

                          // Grid
                          Expanded(
                            child: GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate: _getResponsiveGridDelegate(),
                              itemCount: stores.length,
                              itemBuilder: (context, index) {
                                final store = stores[index];
                                return StoreCard(
                                  store: store,
                                  onTap: () {
                                    ref
                                        .read(currentStoreProvider.notifier)
                                        .state = store;
                                    NavigationService.instance.navigateTo(
                                      NavigatorRoutes.productListScreen,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () {
                  if (_previousTag != null) {
                    return _buildLoadingState();
                  }
                  if (storesAsyncValue.hasValue &&
                      storesAsyncValue.value!.stores.isNotEmpty) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => ref
                          .read(storesViewModelProvider.notifier)
                          .refreshStores(),
                      child: Padding(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width < 320
                                ? 8.0
                                : 16.0),
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate: _getResponsiveGridDelegate(),
                          itemCount: storesAsyncValue.value!.stores.length,
                          itemBuilder: (context, index) {
                            final store = storesAsyncValue.value!.stores[index];
                            return StoreCard(
                              store: store,
                              onTap: () {
                                ref.read(currentStoreProvider.notifier).state =
                                    store;
                                NavigationService.instance.navigateTo(
                                  NavigatorRoutes.productListScreen,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return _buildLoadingState();
                },
                error: (error, stack) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => ref
                        .read(storesViewModelProvider.notifier)
                        .refreshStores(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: _buildErrorState(error),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DotSpinningIndicator(
              color: AppColors.primary,
            ),
            Gap.h16,
            const Text(
              'Finding stores near you...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_outlined,
              color: Colors.grey[400],
              size: 40,
            ),
          ),
          Gap.h20,
          Text(
            'No stores found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Gap.h8,
          Text(
            'Try adjusting your search or check back later',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          Gap.h24,
          TextButton.icon(
            onPressed: () {
              ref.read(storesViewModelProvider.notifier).refreshStores();
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red[100]!,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.wifi_off,
              color: Colors.red[400],
              size: 40,
            ),
          ),

          Gap.h20,

          // Error Title
          Text(
            'Connection Problem',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),

          Gap.h8,

          // Error Description
          Text(
            'Unable to load stores. Please check your\ninternet connection and try again.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          Gap.h24,

          // Retry Button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
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
                ref.read(storesViewModelProvider.notifier).refreshStores();
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
