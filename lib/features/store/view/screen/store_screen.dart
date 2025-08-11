import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/store_card.dart';
import 'package:starter_codes/features/store/view_model/store_view_model.dart';
import 'package:starter_codes/widgets/app_bar/empty_app_bar.dart';
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

  @override
  void initState() {
    super.initState();
    // Initial fetch of stores when the screen is first loaded.
    // The ViewModel's stale time logic will determine if a network call is needed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storesViewModelProvider.notifier).fetchStoresIfStale();
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

  @override
  Widget build(BuildContext context) {
    final storesAsyncValue = ref.watch(storesViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const EmptyAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with Search
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with location icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Stores Around You',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Find nearby stores and shops',
                              style: TextStyle(
                                fontSize: 14,
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
                          padding: const EdgeInsets.all(12),
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
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
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
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.85,
                              ),
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
                  // If there's already data, display it while a refresh happens in the background.
                  if (storesAsyncValue.hasValue &&
                      storesAsyncValue.value!.stores.isNotEmpty) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => ref
                          .read(storesViewModelProvider.notifier)
                          .refreshStores(),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
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
                  // Initial loading state
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
