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
import 'package:starter_codes/widgets/empty_content.dart';
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
      ref.read(storesViewModelProvider.notifier).filterStoresBySearch(_searchController.text);
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
      appBar: const EmptyAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stores Around you',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Gap.h16,
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stores...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
            Gap.h16,
            Expanded(
              child: storesAsyncValue.when(
                data: (storeResponse) {
                  final List<Store> stores = storeResponse.stores;
                  if (stores.isEmpty) {
                    return RefreshIndicator( // Keep RefreshIndicator even for empty state
                      color: AppColors.primary,
                      onRefresh: () => ref.read(storesViewModelProvider.notifier).refreshStores(),
                      child:  SingleChildScrollView( // Make empty state scrollable for RefreshIndicator
                        physics:const AlwaysScrollableScrollPhysics(),
                        child: Center(
                          child: Column(
                            children: [
                              Gap.h32, // Add some space
                            const  EmptyContent(contentText: 'No stores found.',icon: Icons.store,),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => ref.read(storesViewModelProvider.notifier).refreshStores(),
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: stores.length,
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        return StoreCard(
                          store: store,
                          onTap: () {
                            ref.read(currentStoreProvider.notifier).state = store;
                            NavigationService.instance.navigateTo(
                              NavigatorRoutes.productListScreen,
                              // arguments: store.id, // Uncomment if you pass store ID
                            );
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () {
                  // If there's already data, display it while a refresh happens in the background.
                  // The RefreshIndicator itself shows the loading animation.
                  if (storesAsyncValue.hasValue && storesAsyncValue.value!.stores.isNotEmpty) {
                    return RefreshIndicator( // Wrap existing data display in RefreshIndicator
                      color: AppColors.primary,
                      onRefresh: () => ref.read(storesViewModelProvider.notifier).refreshStores(),
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(), // Crucial for RefreshIndicator
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: storesAsyncValue.value!.stores.length,
                        itemBuilder: (context, index) {
                          final store = storesAsyncValue.value!.stores[index];
                          return StoreCard(
                            store: store,
                            onTap: () {
                              ref.read(currentStoreProvider.notifier).state = store;
                              NavigationService.instance.navigateTo(
                                NavigatorRoutes.productListScreen,
                              );
                            },
                          );
                        },
                      ),
                    );
                  }
                  // Otherwise, show a full-screen loading indicator for the initial load
                  return const Center(
                    child: DotSpinningIndicator(
                      color: AppColors.primary,
                    ),
                  );
                },
                error: (error, stack) {
                  return RefreshIndicator( // Wrap error state in RefreshIndicator
                    color: AppColors.primary,
                    onRefresh: () => ref.read(storesViewModelProvider.notifier).refreshStores(),
                    child: SingleChildScrollView( // Make error state scrollable for RefreshIndicator
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Gap.h32, // Add some space
                            Text('Error loading stores: ${error.toString()}'),
                            Gap.h16,
                            ElevatedButton(
                              onPressed: () {
                                ref.read(storesViewModelProvider.notifier).refreshStores();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
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
}