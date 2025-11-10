import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/delivery/model/delivery_item.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/features/delivery/view/widget/custom_tab_bar.dart';
import 'package:starter_codes/features/delivery/view/widget/delivery_list_view.dart';
import 'package:starter_codes/widgets/app_bar/empty_app_bar.dart';
import 'package:starter_codes/features/delivery/view_model/delivery_view_model.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/dot_spinning_indicator.dart';
import 'package:starter_codes/widgets/empty_content.dart';
import 'package:starter_codes/widgets/gap.dart';

class DeliveryScreen extends ConsumerStatefulWidget {
  const DeliveryScreen({super.key});

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends ConsumerState<DeliveryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const Set<String> _successfulPaymentStatuses = {
    'success',
    'successful',
    'paid',
    'completed',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initial fetch for the first tab (Package Deliveries)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deliveryViewModelProvider).fetchPackageDeliveries();
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          ref.read(deliveryViewModelProvider).fetchPackageDeliveries();
        } else {
          ref.read(deliveryViewModelProvider).fetchStoreDeliveries();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {}); // Remove listener before disposing
    _tabController.dispose();
    super.dispose();
  }

  // Helper method for pull-to-refresh
  Future<void> _onRefresh(OrderTabType tabType) async {
    await ref.read(deliveryViewModelProvider).refreshOrders(tabType);
  }

  Widget _buildErrorWidget(String? errorMessage, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add the icon here
            const Icon(
              Icons.error_outline, // You can choose any icon here
              color: AppColors.greyLight,
              size: 50,
            ),
            const SizedBox(height: 16), // Add some spacing below the icon
            const Text(
              'Failed to load deliveries. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
            Gap.h4,
            AppButton.primary(title: 'Try Again', onTap: onRetry),
          ],
        ),
      ),
    );
  }

  // A helper function to handle retries for each tab
  void _onRetry(OrderTabType tabType) {
    if (tabType == OrderTabType.packageDelivery) {
      ref.read(deliveryViewModelProvider).fetchPackageDeliveries();
    } else {
      ref.read(deliveryViewModelProvider).fetchStoreDeliveries();
    }
  }

  bool _hasSuccessfulPayment(DeliveryModel delivery) {
    final status = delivery.paymentStatus?.toLowerCase().trim();
    if (status == null) return false;
    return _successfulPaymentStatuses.contains(status);
  }

  @override
  Widget build(BuildContext context) {
    final deliveryViewModel = ref.watch(deliveryViewModelProvider);

    final List<DeliveryModel> rawPackageDeliveries =
        deliveryViewModel.packageDeliveries;
    final List<DeliveryModel> rawStoreDeliveries =
        deliveryViewModel.storeDeliveries;

    final List<DeliveryModel> successfulPackageDeliveries =
        rawPackageDeliveries.where(_hasSuccessfulPayment).toList();
    final List<DeliveryModel> successfulStoreDeliveries =
        rawStoreDeliveries.where(_hasSuccessfulPayment).toList();

    final List<DeliveryItem> displayPackageDeliveries =
        successfulPackageDeliveries
            .map((delivery) => DeliveryItem.fromDeliveryModel(delivery))
            .toList();

    final List<DeliveryItem> displayStoreDeliveries = successfulStoreDeliveries
        .map((delivery) => DeliveryItem.fromDeliveryModel(delivery))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const EmptyAppBar(),
      body: Column(
        children: [
          CustomTabBar(tabController: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Package Deliveries Tab Content
                RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => _onRefresh(OrderTabType.packageDelivery),
                  child: deliveryViewModel.isLoadingPackageDeliveries &&
                          displayPackageDeliveries.isEmpty
                      ? const Center(child: DotSpinningIndicator())
                      : deliveryViewModel.packageDeliveryError != null
                          ? _buildErrorWidget(
                              deliveryViewModel.packageDeliveryError,
                              () => _onRetry(OrderTabType.packageDelivery),
                            )
                          : displayPackageDeliveries.isEmpty
                              ? const Center(
                                  child: EmptyContent(
                                  contentText: 'No package deliveries found.',
                                  icon: Icons.delivery_dining,
                                ))
                              : DeliveryListView(
                                  deliveries: displayPackageDeliveries,
                                  originalDeliveries:
                                      successfulPackageDeliveries,
                                ),
                ),

                // Store Deliveries Tab Content
                RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => _onRefresh(OrderTabType.storeDelivery),
                  child: deliveryViewModel.isLoadingStoreDeliveries &&
                          displayStoreDeliveries.isEmpty
                      ? const Center(child: DotSpinningIndicator())
                      : deliveryViewModel.storeDeliveryError != null
                          ? _buildErrorWidget(
                              deliveryViewModel.storeDeliveryError,
                              () => _onRetry(OrderTabType.storeDelivery),
                            )
                          : displayStoreDeliveries.isEmpty
                              ? const Center(
                                  child: EmptyContent(
                                  contentText:
                                      'No successful store deliveries found.',
                                  icon: Icons.store,
                                ))
                              : DeliveryListView(
                                  deliveries: displayStoreDeliveries,
                                  originalDeliveries: successfulStoreDeliveries,
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
