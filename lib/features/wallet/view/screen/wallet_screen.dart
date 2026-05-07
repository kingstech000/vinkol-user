import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/extensions/double_extension.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/core/utils/textstyles.dart';
import 'package:starter_codes/features/wallet/view/widget/fund_wallet_sheet.dart';
import '../../view_model/wallet_history_view_model.dart';
import '../../data/wallet_service.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/core/utils/network_client.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import '../../model/payment_history_model.dart';
import '../../view_model/withdrawal_view_model.dart';
import '../widget/withdrawal_item.dart';
import 'withdraw_screen.dart';
import 'transaction_detail_screen.dart';

final walletServiceProvider = Provider((ref) {
  return WalletService(NetworkClient(), const AppLogger(WalletService));
});

class WalletHistoryScreen extends ConsumerStatefulWidget {
  const WalletHistoryScreen({super.key});

  @override
  ConsumerState<WalletHistoryScreen> createState() =>
      _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends ConsumerState<WalletHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletOverviewViewModelProvider.notifier).refreshData();
      ref.read(withdrawalProvider.notifier).refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletOverviewState = ref.watch(walletOverviewViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        toolbarHeight: 80.h,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap.h12,
                    AppText.h1(
                      'Wallet',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    Gap.h8,
                    AppText.caption(
                      'Manage your wallet and transactions',
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait<void>([
            ref.read(walletOverviewViewModelProvider.notifier).refreshData(),
            ref.read(withdrawalProvider.notifier).refreshData(),
          ]);
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: (() {
                    final wb = walletOverviewState.walletBalance;
                    if (wb is AsyncData<double>) {
                      return _buildWalletHeader(wb.value);
                    }
                    if (wb is AsyncLoading<double>) {
                      return _buildWalletHeaderLoading();
                    }
                    if (wb is AsyncError<double>) return _buildErrorStats();
                    return const SizedBox.shrink();
                  }()),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.blue,
                    labelStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: 'Payments'),
                      Tab(text: 'Withdrawals'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: Container(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPaymentHistoryTab(walletOverviewState),
                _buildWithdrawalHistoryTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryTab(dynamic walletOverviewState) {
    final historyState = walletOverviewState.withdrawalHistory;

    if (historyState is AsyncLoading<List<PaymentHistory>>) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blue),
      );
    }

    if (historyState is AsyncError<List<PaymentHistory>>) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
              Gap.h16,
              Text(
                'Error loading history',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      );
    }

    if (historyState is AsyncData<List<PaymentHistory>>) {
      final history = historyState.value;
      if (history.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64.sp, color: Colors.grey.shade300),
                Gap.h16,
                Text(
                  'No payment history',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Gap.h8,
                Text(
                  'Your payment transactions will appear here',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: history.length,
        separatorBuilder: (context, index) => Gap.h12,
        itemBuilder: (context, index) {
          final payment = history[index];
          final isDebit = payment.type == 'Debit';
          final dateFormat = payment.createdAt.toLocal();
          final formattedDate =
              '${dateFormat.day}/${dateFormat.month}/${dateFormat.year}';
          final formattedTime =
              '${dateFormat.hour.toString().padLeft(2, '0')}:${dateFormat.minute.toString().padLeft(2, '0')}';

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TransactionDetailScreen(transaction: payment),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color:
                            isDebit ? Colors.red.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        isDebit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isDebit
                            ? Colors.red.shade600
                            : Colors.green.shade600,
                        size: 20.sp,
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.narration.isNotEmpty
                                ? payment.narration
                                : (isDebit ? 'Payment' : 'Funding'),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Gap.h4,
                          Text(
                            '$formattedDate at $formattedTime',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isDebit ? '-' : '+'}${payment.amount.toMoney()}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: isDebit
                                ? Colors.red.shade600
                                : Colors.green.shade600,
                          ),
                        ),
                        Gap.h4,
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: payment.status.toLowerCase() ==
                                        'successful' ||
                                    payment.status.toLowerCase() == 'success'
                                ? Colors.green.shade50
                                : payment.status.toLowerCase() == 'pending'
                                    ? Colors.orange.shade50
                                    : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            payment.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: payment.status.toLowerCase() ==
                                          'successful' ||
                                      payment.status.toLowerCase() == 'success'
                                  ? Colors.green.shade700
                                  : payment.status.toLowerCase() == 'pending'
                                      ? Colors.orange.shade700
                                      : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildWithdrawalHistoryTab() {
    return Consumer(
      builder: (context, ref, _) {
        final withdrawalState = ref.watch(withdrawalProvider);
        final wh = withdrawalState.withdrawalHistory;

        if (wh is AsyncLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.blue),
          );
        }

        if (wh is AsyncError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                  Gap.h16,
                  Text(
                    'Error loading withdrawals',
                    style:
                        TextStyle(fontSize: 16.sp, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          );
        }

        if (wh is AsyncData) {
          final resp = wh.value;
          final list = resp?.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet,
                        size: 64.sp, color: Colors.grey.shade300),
                    Gap.h16,
                    Text(
                      'No withdrawals yet',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Gap.h8,
                    Text(
                      'Your withdrawal requests will appear here',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: list.length,
            separatorBuilder: (context, index) => Gap.h12,
            itemBuilder: (context, index) {
              return WithdrawalItem(withdrawal: list[index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildWalletHeader(double balance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Wallet Balance',
              style: headingStyle5,
            ),
            IconButton(
              icon: Icon(Icons.refresh, size: 30.sp, color: AppColors.blue),
              onPressed: () {
                ref
                    .read(walletOverviewViewModelProvider.notifier)
                    .refreshData();
                ref.read(withdrawalProvider.notifier).refreshData();
              },
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
        Gap.h8,
        Text(
          balance.toMoney(),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        Gap.h20,
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => showFundDialog(context, ref, mounted),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.blue, AppColors.blue.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        Gap.w6,
                        Flexible(
                          child: Text(
                            'Fund Wallet',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Gap.w12,
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WithdrawScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.blue, width: 2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.send_rounded,
                          color: AppColors.blue,
                          size: 22.sp,
                        ),
                        Gap.w8,
                        Text(
                          'Withdraw',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletHeaderLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wallet Balance',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox(
          height: 32,
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  Widget _buildErrorStats() {
    return Center(
      child: Text(
        'Error loading balance',
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
