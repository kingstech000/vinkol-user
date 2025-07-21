import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/wallet/view/widget/withdrawal_item.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/widgets/app_bar/empty_app_bar.dart';
import 'package:starter_codes/widgets/empty_content.dart';
import 'package:starter_codes/widgets/gap.dart';

class WalletHistoryScreen extends ConsumerStatefulWidget {
  const WalletHistoryScreen({super.key});

  @override
  ConsumerState<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends ConsumerState<WalletHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Initial fetch when the screen is first loaded.
    // The ViewModel's stale time logic will prevent unnecessary fetches on subsequent builds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletOverviewViewModelProvider.notifier).refreshData(); // Call refreshData to trigger initial fetch
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🟣 WalletHistoryScreen: BUILD METHOD CALLED');

    final walletOverviewState = ref.watch(walletOverviewViewModelProvider);
    final withdrawalHistoryAsync = walletOverviewState.withdrawalHistory;
    // final walletBalanceAsync = walletOverviewState.walletBalance; // Not used in UI display

  

    return Scaffold(
      appBar: const EmptyAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: AppText.h5(
              'Payment History',
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: RefreshIndicator(color: AppColors.primary,     
              onRefresh: () => ref.read(walletOverviewViewModelProvider.notifier).refreshData(),
              child: withdrawalHistoryAsync.when(
                data: (history) {
                  if (history.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator on empty list
                      child: 
                        Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Gap.h32,
                         const   Center(
                              child: EmptyContent(
                              contentText:   'No payment history found.',
                              icon: Icons.credit_card,
                                ),
                            ),
                          ],
                        ),
                      
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      // Date/time formatters are now passed into PaymentHistoryItem if needed,
                      // or handled within PaymentHistoryItem itself.
                      // final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');
                      // final DateFormat timeFormatter = DateFormat('hh:mm a');

                      return PaymentHistoryItem(
                        payment: item,
                        // If PaymentHistoryItem needs these, pass them:
                        // dateFormatter: dateFormatter,
                        // timeFormatter: timeFormatter,
                      );
                    },
                  );
                },
                loading: () {
                   // If there's already data, display it while a refresh happens in the background.
                   // The RefreshIndicator itself shows the loading animation.
                   if (withdrawalHistoryAsync.hasValue && withdrawalHistoryAsync.value!.isNotEmpty) {
                     return ListView.builder(
                       physics: const AlwaysScrollableScrollPhysics(),
                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                       itemCount: withdrawalHistoryAsync.value!.length,
                       itemBuilder: (context, index) {
                         final item = withdrawalHistoryAsync.value![index];
                         return PaymentHistoryItem(payment: item);
                       },
                     );
                   }
                   // Otherwise, show a full-screen loading indicator for the initial load
                   return SingleChildScrollView(
                     physics: const AlwaysScrollableScrollPhysics(),
                     child: Center(
                       child: Column(
                         children: [
                           Gap.h32,
                           const CircularProgressIndicator(color: AppColors.primary),
                         ],
                       ),
                     ),
                   );
                },
                error: (e, s) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: Column(
                      children: [
                        Gap.h32,
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Failed to load withdrawal history.\n${e.toString()}', // Show error message for debugging
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}