// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:starter_codes/core/utils/colors.dart';
// import 'package:starter_codes/core/utils/text.dart';
// import '../../widget/withdrawal_item.dart';
// import '../../view_model/wallet_history_view_model.dart';
// import '../../data/wallet_service.dart';
// import 'package:starter_codes/features/payment/view/payment_webview.dart';
// import 'package:starter_codes/widgets/gap.dart';

// class WalletHistoryScreen extends ConsumerStatefulWidget {
//   const WalletHistoryScreen({super.key});

//   @override
//   ConsumerState<WalletHistoryScreen> createState() =>
//       _WalletHistoryScreenState();
// }

// class _WalletHistoryScreenState extends ConsumerState<WalletHistoryScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(walletOverviewViewModelProvider.notifier).refreshData();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     debugPrint('🟣 WalletHistoryScreen: BUILD METHOD CALLED');
//     final walletOverviewState = ref.watch(walletOverviewViewModelProvider);
//     final withdrawalHistoryAsync = walletOverviewState.withdrawalHistory;
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         toolbarHeight: 80.h,
//         scrolledUnderElevation: 0,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Container(
//           padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Gap.h12,
//                     AppText.h1(
//                       'Payment History',
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     Gap.h8,
//                     AppText.caption(
//                       'View your payment history',
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Header Section with Statistics
//           Container(
//             margin: const EdgeInsets.all(20),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: walletOverviewState.walletBalance.when(
//               data: (balance) => _buildWalletHeader(balance),
//               loading: () => _buildWalletHeaderLoading(),
//               error: (e, s) => _buildErrorStats(),
//             ),
//           ),

//           // Content Section
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: RefreshIndicator(
//                 color: AppColors.primary,
//                 onRefresh: () => ref
//                     .read(walletOverviewViewModelProvider.notifier)
//                     .refreshData(),
//                 child: withdrawalHistoryAsync.when(
//                   data: (history) => _buildHistoryList(history),
//                   loading: () => _buildLoadingState(withdrawalHistoryAsync),
//                   error: (e, s) => _buildErrorState(e),
//                 ),
//               ),
//             ),
//           ),
//           Gap.h20,
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsSection(List<dynamic> history) {
//     final totalTransactions = history.length;
//     final pendingCount =
//         history.where((item) => item.status?.toLowerCase() == 'pending').length;
//     final completedCount = history
//         .where((item) =>
//             item.status?.toLowerCase() == 'completed' ||
//             item.status?.toLowerCase() == 'success' ||
//             item.status?.toLowerCase() == 'successful')
//         .length;

//     return Row(
//       children: [
//         Expanded(
//           child: _buildStatItem(
//             icon: Icons.receipt_long_outlined,
//             label: 'Total',
//             value: '$totalTransactions',
//             color: AppColors.primary,
//           ),
//         ),
//         Container(
//           height: 40,
//           width: 1,
//           color: Colors.grey.shade200,
//         ),
//         Expanded(
//           child: _buildStatItem(
//             icon: Icons.access_time,
//             label: 'Pending',
//             value: '$pendingCount',
//             color: Colors.orange,
//           ),
//         ),
//         Container(
//           height: 40,
//           width: 1,
//           color: Colors.grey.shade200,
//         ),
//         Expanded(
//           child: _buildStatItem(
//             icon: Icons.check_circle_outline,
//             label: 'Completed',
//             value: '$completedCount',
//             color: Colors.green,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildWalletHeader(double balance) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AppText.h1(
//           'Wallet Balance',
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//         Gap.h4,
//         Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   AppText.caption(
//                     'Available balance',
//                     color: Colors.grey[600],
//                     fontSize: 12.sp,
//                   ),
//                   Gap.h8,
//                   AppText.h2('₦${balance.toStringAsFixed(2)}',
//                       fontSize: 28, fontWeight: FontWeight.bold),
//                   Gap.h8,
//                 ],
//               ),
//             ),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             SizedBox(
//               height: 40,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: Colors.white,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () => _showFundDialog(),
//                 child: const Text('Fund Wallet'),
//               ),
//             ),
//             SizedBox(
//               height: 40,
//               child: OutlinedButton(
//                 style: OutlinedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text('Withdraw feature not implemented yet')),
//                   );
//                 },
//                 child: const Text('Withdraw'),
//               ),
//             ),
//           ],
//         )
//       ],
//     );
//   }

//   Widget _buildWalletHeaderLoading() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AppText.h1('Wallet Balance', fontSize: 18, fontWeight: FontWeight.bold),
//         Gap.h12,
//         Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                       width: 180, height: 28, color: Colors.grey.shade200),
//                   Gap.h8,
//                   Container(
//                       width: 120, height: 12, color: Colors.grey.shade200),
//                 ],
//               ),
//             ),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(width: 100, height: 40, color: Colors.grey.shade200),
//                 Gap.w8,
//                 Container(width: 80, height: 40, color: Colors.grey.shade200),
//               ],
//             )
//           ],
//         ),
//       ],
//     );
//   }

//   void _showFundDialog() {
//     showModalBottomSheet<void>(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       builder: (context) {
//         final TextEditingController _amountController = TextEditingController();
//         bool _isLoading = false;

//         return StatefulBuilder(builder: (context, setState) {
//           return Padding(
//             padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   AppText.h4('Fund Wallet', fontWeight: FontWeight.bold),
//                   Gap.h12,
//                   TextField(
//                     controller: _amountController,
//                     keyboardType:
//                         TextInputType.numberWithOptions(decimal: true),
//                     decoration: const InputDecoration(
//                       labelText: 'Amount',
//                       prefixText: '₦',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   Gap.h12,
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isLoading
//                           ? null
//                           : () async {
//                               final text = _amountController.text.trim();
//                               if (text.isEmpty) return;
//                               final amount = double.tryParse(text);
//                               if (amount == null || amount <= 0) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                         content: Text('Enter a valid amount')));
//                                 return;
//                               }
//                               setState(() => _isLoading = true);
//                               try {
//                                 final data = await ref
//                                     .read(walletServiceProvider)
//                                     .fundWallet(amount);
//                                 final url =
//                                     data['authorization_url'] as String?;
//                                 final reference =
//                                     data['reference']?.toString() ?? '';
//                                 if (url != null && url.isNotEmpty) {
//                                   Navigator.of(context).pop();
//                                   Navigator.of(this.context)
//                                       .push(MaterialPageRoute(
//                                     builder: (context) => PaymentWebViewScreen(
//                                       paymentUrl: url,
//                                       orderId: reference,
//                                       reference: reference,
//                                     ),
//                                   ));
//                                 } else {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                           content: Text(
//                                               'Unable to generate payment link')));
//                                 }
//                               } catch (e) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                         content:
//                                             Text('Error: ${e.toString()}')));
//                               } finally {
//                                 if (mounted) setState(() => _isLoading = false);
//                               }
//                             },
//                       child: _isLoading
//                           ? const SizedBox(
//                               height: 18,
//                               width: 18,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Text('Proceed to Pay'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//       },
//     );
//   }

//   Widget _buildStatItem({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         Gap.h8,
//         AppText.h4(
//           value,
//           color: Colors.black87,
//           fontWeight: FontWeight.bold,
//         ),
//         AppText.caption(
//           label,
//           color: Colors.grey.shade600,
//           fontSize: 12,
//         ),
//       ],
//     );
//   }

//   Widget _buildLoadingStats() {
//     return Row(
//       children: [
//         Expanded(child: _buildStatItemSkeleton()),
//         Container(height: 40, width: 1, color: Colors.grey.shade200),
//         Expanded(child: _buildStatItemSkeleton()),
//         Container(height: 40, width: 1, color: Colors.grey.shade200),
//         Expanded(child: _buildStatItemSkeleton()),
//       ],
//     );
//   }

//   Widget _buildStatItemSkeleton() {
//     return Column(
//       children: [
//         Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         Gap.h8,
//         Container(
//           width: 24,
//           height: 16,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//         Gap.h4,
//         Container(
//           width: 40,
//           height: 12,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildErrorStats() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Icon(Icons.error_outline, color: Colors.red, size: 20),
//         Gap.w8,
//         AppText.caption('Unable to load statistics', color: Colors.red),
//       ],
//     );
//   }

//   Widget _buildHistoryList(List<dynamic> history) {
//     if (history.isEmpty) {
//       return _buildEmptyState();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               const Icon(Icons.history, color: AppColors.primary, size: 20),
//               Gap.w8,
//               AppText.button(
//                 'Recent Transactions',
//                 color: Colors.black87,
//                 fontWeight: FontWeight.w600,
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: ListView.separated(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
//             itemCount: history.length,
//             separatorBuilder: (context, index) => Divider(
//               color: Colors.grey.shade200,
//               height: 1,
//               indent: 16,
//               endIndent: 16,
//             ),
//             itemBuilder: (context, index) {
//               final item = history[index];
//               return PaymentHistoryItem(payment: item);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLoadingState(AsyncValue<List<dynamic>> withdrawalHistoryAsync) {
//     if (withdrawalHistoryAsync.hasValue &&
//         withdrawalHistoryAsync.value!.isNotEmpty) {
//       return _buildHistoryList(withdrawalHistoryAsync.value!);
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(50),
//             ),
//             child: const CircularProgressIndicator(
//               color: AppColors.primary,
//               strokeWidth: 3,
//             ),
//           ),
//           Gap.h20,
//           AppText.button(
//             'Loading transactions...',
//             color: Colors.black87,
//             fontWeight: FontWeight.w500,
//           ),
//           Gap.h8,
//           AppText.caption(
//             'Please wait while we fetch your data',
//             color: Colors.grey.shade600,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(dynamic error) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child:
//                   const Icon(Icons.error_outline, color: Colors.red, size: 40),
//             ),
//             Gap.h20,
//             AppText.button(
//               'Something went wrong',
//               color: Colors.black87,
//               fontWeight: FontWeight.w500,
//             ),
//             Gap.h8,
//             AppText.caption(
//               'We couldn\'t load your payment history. Please check your connection and try again.',
//               color: Colors.grey.shade600,
//               textAlign: TextAlign.center,
//             ),
//             Gap.h20,
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () {
//                 ref
//                     .read(walletOverviewViewModelProvider.notifier)
//                     .refreshData();
//               },
//               icon: const Icon(Icons.refresh, size: 18),
//               label: const Text('Try Again'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.grey.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(60),
//               ),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(40),
//                 ),
//                 child: const Icon(Icons.receipt_long_outlined,
//                     size: 48, color: Colors.grey),
//               ),
//             ),
//             Gap.h24,
//             AppText.h5(
//               'No payments yet',
//               color: Colors.black87,
//               fontWeight: FontWeight.w700,
//             ),
//             Gap.h8,
//             AppText.caption(
//               'Your payment history will appear here once you start making transactions',
//               color: Colors.grey.shade600,
//               fontSize: 12,
//               textAlign: TextAlign.center,
//             ),
//             Gap.h24,
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(
//                     Icons.info_outline,
//                     size: 16,
//                     color: AppColors.primary,
//                   ),
//                   Gap.w8,
//                   AppText.caption(
//                     'Pull down to refresh',
//                     color: AppColors.primary,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
