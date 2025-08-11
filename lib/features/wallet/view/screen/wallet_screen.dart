import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/wallet/view/widget/withdrawal_item.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/widgets/gap.dart';

class WalletHistoryScreen extends ConsumerStatefulWidget {
  const WalletHistoryScreen({super.key});

  @override
  ConsumerState<WalletHistoryScreen> createState() =>
      _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends ConsumerState<WalletHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletOverviewViewModelProvider.notifier).refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🟣 WalletHistoryScreen: BUILD METHOD CALLED');
    final walletOverviewState = ref.watch(walletOverviewViewModelProvider);
    final withdrawalHistoryAsync = walletOverviewState.withdrawalHistory;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText.h4(
          'Payment History',
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        // centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Section with Statistics
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: withdrawalHistoryAsync.when(
              data: (history) => _buildStatsSection(history),
              loading: () => _buildLoadingStats(),
              error: (e, s) => _buildErrorStats(),
            ),
          ),

          // Content Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => ref
                    .read(walletOverviewViewModelProvider.notifier)
                    .refreshData(),
                child: withdrawalHistoryAsync.when(
                  data: (history) => _buildHistoryList(history),
                  loading: () => _buildLoadingState(withdrawalHistoryAsync),
                  error: (e, s) => _buildErrorState(e),
                ),
              ),
            ),
          ),
          Gap.h20,
        ],
      ),
    );
  }

  Widget _buildStatsSection(List<dynamic> history) {
    final totalTransactions = history.length;
    final pendingCount =
        history.where((item) => item.status?.toLowerCase() == 'pending').length;
    final completedCount = history
        .where((item) =>
            item.status?.toLowerCase() == 'completed' ||
            item.status?.toLowerCase() == 'success' ||
            item.status?.toLowerCase() == 'successful')
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.receipt_long_outlined,
            label: 'Total',
            value: '$totalTransactions',
            color: AppColors.primary,
          ),
        ),
        Container(
          height: 40,
          width: 1,
          color: Colors.grey.shade200,
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.access_time,
            label: 'Pending',
            value: '$pendingCount',
            color: Colors.orange,
          ),
        ),
        Container(
          height: 40,
          width: 1,
          color: Colors.grey.shade200,
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.check_circle_outline,
            label: 'Completed',
            value: '$completedCount',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        Gap.h8,
        AppText.h4(
          value,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        AppText.caption(
          label,
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ],
    );
  }

  Widget _buildLoadingStats() {
    return Row(
      children: [
        Expanded(child: _buildStatItemSkeleton()),
        Container(height: 40, width: 1, color: Colors.grey.shade200),
        Expanded(child: _buildStatItemSkeleton()),
        Container(height: 40, width: 1, color: Colors.grey.shade200),
        Expanded(child: _buildStatItemSkeleton()),
      ],
    );
  }

  Widget _buildStatItemSkeleton() {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Gap.h8,
        Container(
          width: 24,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Gap.h4,
        Container(
          width: 40,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 20),
        Gap.w8,
        AppText.caption('Unable to load statistics', color: Colors.red),
      ],
    );
  }

  Widget _buildHistoryList(List<dynamic> history) {
    if (history.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.history, color: AppColors.primary, size: 20),
              Gap.w8,
              AppText.button(
                'Recent Transactions',
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            itemCount: history.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey.shade200,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final item = history[index];
              return PaymentHistoryItem(payment: item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(AsyncValue<List<dynamic>> withdrawalHistoryAsync) {
    if (withdrawalHistoryAsync.hasValue &&
        withdrawalHistoryAsync.value!.isNotEmpty) {
      return _buildHistoryList(withdrawalHistoryAsync.value!);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          Gap.h20,
          AppText.button(
            'Loading transactions...',
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          Gap.h8,
          AppText.caption(
            'Please wait while we fetch your data',
            color: Colors.grey.shade600,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child:
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
            ),
            Gap.h20,
            AppText.button(
              'Something went wrong',
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            Gap.h8,
            AppText.caption(
              'We couldn\'t load your payment history. Please check your connection and try again.',
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
            ),
            Gap.h20,
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                ref
                    .read(walletOverviewViewModelProvider.notifier)
                    .refreshData();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.receipt_long_outlined,
                    size: 48, color: Colors.grey),
              ),
            ),
            Gap.h24,
            AppText.h5(
              'No payments yet',
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            Gap.h8,
            AppText.caption(
              'Your payment history will appear here once you start making transactions',
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
            ),
            Gap.h24,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  Gap.w8,
                  AppText.caption(
                    'Pull down to refresh',
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
