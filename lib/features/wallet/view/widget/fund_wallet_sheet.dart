import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/extensions/currency_formatter.dart';
import 'package:starter_codes/core/extensions/double_extension.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/payment/view/payment_webview.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/features/wallet/view_model/withdrawal_view_model.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';

/// There are no customer wallets in Canada, so wallet amounts are always naira.
/// The symbol and decimal places still come from the market layer rather than
/// being written into the screen.
const Currency _walletCurrency = Currency.ngn;
const double _minimumTopUp = 100;

void showFundDialog(BuildContext context, WidgetRef ref, bool mounted) {
  final amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isProcessing = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24.w,
          right: 24.w,
          top: 24.h,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Gap.h24,
                // Title
                AppText.h2(
                  'Fund Wallet',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
                Gap.h8,
                AppText.body(
                  'Enter the amount you want to add to your wallet',
                  color: Colors.grey.shade600,
                  fontSize: 14.sp,
                ),
                Gap.h24,
                // Quick amount buttons
                Text(
                  'Quick Amount',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Gap.h12,
                Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: [1000, 5000, 10000, 20000]
                      .map((amount) => InkWell(
                            onTap: () {
                              amountController.text =
                                  double.parse(amount.toString())
                                      .toMoneyWithoutSymbol();
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.blue.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                double.parse(amount.toString()).toMoney(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blue,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                Gap.h24,
                // Amount input
                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Gap.h8,
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  enabled: !isProcessing,
                  inputFormatters: [CurrencyFormatter.amountFormatter],
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
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
                      borderSide:
                          const BorderSide(color: AppColors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
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
                    final amount = CurrencyFormatter.parseAmount(value);
                    if (amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    if (amount < _minimumTopUp) {
                      return 'Minimum amount is '
                          '${Money(_minimumTopUp, _walletCurrency).format()}';
                    }
                    return null;
                  },
                ),
                Gap.h32,
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            isProcessing ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  final amount = CurrencyFormatter.parseAmount(
                                      amountController.text);
                                  setState(() => isProcessing = true);
                                  _fundWallet(amount, ref, context, mounted)
                                      .then((_) {
                                    Navigator.pop(context);
                                  }).catchError((error) {
                                    setState(() => isProcessing = false);
                                  });
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
                        child: isProcessing
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Continue',
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
                Gap.h24,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _fundWallet(
    double amount, WidgetRef ref, BuildContext context, bool mounted) async {
  try {
    final walletService = ref.read(walletServiceProvider);
    final data = await walletService.fundWallet(amount, 'Paystack');

    if (data['authorization_url'] != null && mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            paymentUrl: data['authorization_url'],
            orderId: data['order_id'] ?? '',
            reference: data['reference'] ?? data['trxref'] ?? '',
            isStoreOrder: false,
            isWalletFunding: true,
          ),
        ),
      );

      // Only refresh wallet data if payment was completed successfully
      if (mounted && result == true) {
        await ref.read(walletOverviewViewModelProvider.notifier).refreshData();
      }
    } else {
      if (mounted) {
        if (mounted) {
          AppStatusDialogs.showError(context, 'Error',
              'Unable to generate payment link. Please try again.');
        }
      }
    }
  } catch (error) {
    if (mounted) {
      if (mounted) {
        AppStatusDialogs.showError(
            context, 'Error', 'Error: ${error.toString()}');
      }
    }
    rethrow;
  }
}
