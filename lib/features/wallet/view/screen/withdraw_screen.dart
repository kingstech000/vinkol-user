import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/extensions/double_extension.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/text.dart';
import '../../model/withdrawable_amount_model.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/widgets/gap.dart';
import '../../view_model/withdrawal_view_model.dart';
import '../widget/bank_account_card.dart';
import 'add_bank_screen.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import '../../view_model/wallet_history_view_model.dart';
import '../widget/withdrawal_confirmation_sheet.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  /// There are no customer wallets in Canada, so wallet amounts are always naira.
  /// The symbol and decimal places still come from the market layer rather than
  /// being written into the screen.
  static const Currency _walletCurrency = Currency.ngn;
  static const double _minimumWithdrawal = 100;

  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletOverviewViewModelProvider.notifier).refreshData();
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog(double amount, String? reason) {
    final withdrawalState = ref.read(withdrawalProvider);
    final userBank = withdrawalState.userBank.value;

    if (userBank == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WithdrawalConfirmationSheet(
        amount: amount,
        reason: reason,
        userBank: userBank,
        onConfirm: () {
          Navigator.pop(context);
          _submitWithdrawal(amount, reason);
        },
      ),
    );
  }

  Future<void> _submitWithdrawal(double amount, String? reason) async {
    try {
      await ref.read(withdrawalProvider.notifier).requestWithdrawal(
            amount,
            reason: reason,
          );

      if (mounted) {
        amountController.clear();
        reasonController.clear();
        AppStatusDialogs.showSuccess(
            context, 'Success', 'Withdrawal request submitted successfully');

        // Refresh wallet balance
        await ref.read(walletOverviewViewModelProvider.notifier).refreshData();

        // Refresh withdrawal history
        await ref.read(withdrawalProvider.notifier).refreshData();
      }
    } catch (e) {
      if (mounted) {
        AppStatusDialogs.showError(context, 'Error', 'Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final withdrawalState = ref.watch(withdrawalProvider);
    final walletOverviewState = ref.watch(walletOverviewViewModelProvider);
    final withdrawable = walletOverviewState.withdrawable.valueOrNull;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Withdraw Funds',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(withdrawalProvider.notifier).refreshData();
          await ref
              .read(walletOverviewViewModelProvider.notifier)
              .refreshData();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Balance Card
                // if (walletBalanceValue != null)
                //   Container(
                //     padding: EdgeInsets.all(20.w),
                //     decoration: BoxDecoration(
                //       gradient: LinearGradient(
                //         colors: [
                //           AppColors.blue,
                //           AppColors.blue.withOpacity(0.8)
                //         ],
                //         begin: Alignment.topLeft,
                //         end: Alignment.bottomRight,
                //       ),
                //       borderRadius: BorderRadius.circular(16.r),
                //       boxShadow: [
                //         BoxShadow(
                //           color: AppColors.blue.withOpacity(0.3),
                //           blurRadius: 12,
                //           offset: Offset(0, 4),
                //         ),
                //       ],
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               'Available Balance',
                //               style: TextStyle(
                //                 fontSize: 14.sp,
                //                 color: Colors.white.withOpacity(0.9),
                //               ),
                //             ),
                //             Gap.h8,
                //             Text(
                //               walletBalanceValue.toMoney(),
                //               style: TextStyle(
                //                 fontSize: 28.sp,
                //                 fontWeight: FontWeight.bold,
                //                 color: Colors.white,
                //               ),
                //             ),
                //           ],
                //         ),
                //         Icon(
                //           PhosphorIconsRegular.wallet,
                //           color: Colors.white,
                //           size: 40.sp,
                //         ),
                //       ],
                //     ),
                //   ),
                Gap.h24,
                withdrawalState.userBank.when(
                  data: (userBank) {
                    if (userBank == null) {
                      return _buildNoBankAccountState();
                    }
                    return _buildWithdrawalForm(
                        userBank, withdrawalState, withdrawable);
                  },
                  loading: () => Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 100.h),
                      child: const CircularProgressIndicator(
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                  error: (error, stack) => _buildErrorState(error.toString()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoBankAccountState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsRegular.bank,
              size: 40.sp,
              color: AppColors.blue,
            ),
          ),
          Gap.h24,
          Text(
            'No Bank Account Added',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          Gap.h8,
          Text(
            'Add a bank account to start withdrawing funds from your wallet',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          Gap.h32,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddBankScreen(),
                  ),
                );
                if (result == true && mounted) {
                  await ref.read(withdrawalProvider.notifier).refreshData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Add Bank Account',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm(
      userBank, withdrawalState, WithdrawableAmount? withdrawable) {
    // `/withdraw` refuses anything above the withdrawable amount, so validate
    // against that rather than the balance — otherwise the screen offers a
    // number the server will reject.
    final double? limit = withdrawable?.withdrawableAmount;
    final Currency currency = withdrawable?.currency ?? _walletCurrency;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BankAccountCard(
          bank: userBank,
          onChangeBank: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => const AddBankScreen(),
              ),
            );
            if (result == true && mounted) {
              await ref.read(withdrawalProvider.notifier).refreshData();
            }
          },
        ),
        Gap.h24,
        Text(
          'Withdrawal Amount',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Gap.h12,
        TextFormField(
          controller: amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          enabled: !withdrawalState.isLoading,
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: '${_walletCurrency.symbol} ',
            prefixStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount < _minimumWithdrawal) {
              return 'Minimum withdrawal is '
                  '${Money(_minimumWithdrawal, currency).format()}';
            }
            if (limit != null && amount > limit) {
              return 'Insufficient balance. Available: '
                  '${limit.toMoney(currency)}';
            }
            return null;
          },
        ),
        if (withdrawable != null) ...[
          Gap.h8,
          AppText.caption(
            'Available: ${withdrawable.withdrawable.format()}',
            color: AppColors.darkgrey,
            fontSize: 12,
          ),
          // The gap between the balance and what can be withdrawn is otherwise
          // unexplained, and reads as money going missing.
          if (withdrawable.hasHoldings) ...[
            Gap.h4,
            AppText.caption(
              'Balance ${withdrawable.total.format()}',
              color: AppColors.darkgrey,
              fontSize: 12,
            ),
            if (withdrawable.pendingAmount > 0)
              AppText.caption(
                'Pending withdrawal ${withdrawable.pending.format()}',
                color: AppColors.darkgrey,
                fontSize: 12,
              ),
            if (withdrawable.disputedAmount > 0)
              AppText.caption(
                'Held for disputed orders ${withdrawable.disputed.format()}',
                color: AppColors.darkgrey,
                fontSize: 12,
              ),
          ],
        ],
        Gap.h24,
        Text(
          'Reason (Optional)',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Gap.h12,
        TextFormField(
          controller: reasonController,
          maxLines: 3,
          enabled: !withdrawalState.isLoading,
          decoration: InputDecoration(
            hintText: 'Add a note for this withdrawal...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          style: TextStyle(
            fontSize: 14.sp,
          ),
        ),
        Gap.h32,
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: withdrawalState.isLoading
                ? null
                : () {
                    if (formKey.currentState!.validate()) {
                      final amount = double.parse(amountController.text);
                      final reason = reasonController.text.trim().isEmpty
                          ? null
                          : reasonController.text.trim();
                      _showConfirmationDialog(amount, reason);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: withdrawalState.isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Request Withdrawal',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(
            PhosphorIconsRegular.warningCircle,
            size: 48.sp,
            color: Colors.red,
          ),
          Gap.h16,
          Text(
            'Error Loading Data',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Gap.h8,
          Text(
            error,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
