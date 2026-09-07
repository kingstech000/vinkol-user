import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/delivery/model/delivery_item.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/features/delivery/view/widget/custom_tab_bar.dart';
import 'package:starter_codes/features/delivery/view/widget/delivery_list_view.dart';
import 'package:starter_codes/features/delivery/view_model/delivery_view_model.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/dot_spinning_indicator.dart';
import 'package:starter_codes/widgets/empty_content.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/features/delivery/view/screen/download_report_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.warningCircle,
                color: Colors.red[400],
                size: 64.w,
              ),
            ),
            Gap.h16,
            AppText.h2(
              'Oops! Something went wrong',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              centered: true,
            ),
            Gap.h8,
            AppText.body(
              errorMessage ?? 'Failed to load deliveries. Please try again.',
              fontSize: 14,
              centered: true,
              color: Colors.grey[600],
            ),
            Gap.h24,
            AppButton.primary(
              title: 'Try Again',
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h1(
                  'My Deliveries',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                Gap.h8,
                AppText.caption(
                  'Track and manage your orders',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.blue.withOpacity(0.1),
              padding: EdgeInsets.all(6.w),
              minimumSize: Size.zero,
              side: const BorderSide(color: AppColors.blue),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DownloadReportScreen(),
                ),
              );
            },
            child: Icon(PhosphorIconsRegular.downloadSimple, color: AppColors.blue, size: 20.w),
          )
        ],
      ),
    );
  }

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

    // Calculate summary statistics

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              CustomTabBar(tabController: _tabController),
              Gap.h8,
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
                                        contentText:
                                            'No package deliveries found.\nStart by creating a new order!',
                                        icon: PhosphorIconsRegular.moped,
                                      ),
                                    )
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
                                            'No store deliveries found.\nBrowse stores to place an order!',
                                        icon: PhosphorIconsRegular.storefront,
                                      ),
                                    )
                                  : DeliveryListView(
                                      deliveries: displayStoreDeliveries,
                                      originalDeliveries:
                                          successfulStoreDeliveries,
                                    ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
