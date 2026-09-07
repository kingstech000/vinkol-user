import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/widgets/gap.dart';
import '../../model/bank_model.dart';
import '../../view_model/withdrawal_view_model.dart';
import 'bank_selection_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddBankScreen extends ConsumerStatefulWidget {
  const AddBankScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends ConsumerState<AddBankScreen> {
  final accountNumberController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Bank? selectedBank;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(withdrawalProvider.notifier).clearSession();
    });
    accountNumberController.addListener(_onAccountNumberChanged);
    ref.listenManual(
      withdrawalProvider.select((state) => state.selectedBank),
      (previous, next) {
        if (next != previous && mounted) {
          setState(() {
            selectedBank = next;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    accountNumberController.removeListener(_onAccountNumberChanged);
    accountNumberController.dispose();
    super.dispose();
  }

  void _onAccountNumberChanged() {
    final text = accountNumberController.text;
    if (selectedBank != null && text.length == 10) {
      FocusScope.of(context).unfocus();
      final notifier = ref.read(withdrawalProvider.notifier);
      notifier.validateBank(text, selectedBank!.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final withdrawalState = ref.watch(withdrawalProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Add Bank Account',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Bank Details',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Gap.h8,
              Text(
                'Add your bank account details to receive withdrawals',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              Gap.h32,
              // Select Bank Section
              Text(
                'Select Bank',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Gap.h12,
              withdrawalState.bankList.when(
                data: (banks) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BankSelectionScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: selectedBank != null
                                  ? Colors.green.shade300
                                  : Colors.grey.shade300,
                              width: selectedBank != null ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedBank?.name ?? 'Select Bank',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: selectedBank != null
                                            ? Colors.black
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                PhosphorIconsRegular.caretRight,
                                size: 16.sp,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (selectedBank != null) ...[
                        Gap.h12,
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border.all(
                                color: Colors.green.shade300, width: 2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIconsFill.checkCircle,
                                color: Colors.green.shade600,
                                size: 24.sp,
                              ),
                              Gap.w12,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bank Selected',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Gap.h4,
                                    Text(
                                      selectedBank!.name,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: CircularProgressIndicator(
                      color: AppColors.blue,
                    ),
                  ),
                ),
                error: (error, stack) => Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIconsRegular.warningCircle, color: Colors.red.shade600),
                      Gap.w12,
                      Expanded(
                        child: Text(
                          'Error loading banks: $error',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Gap.h32,
              // Account Number Section
              Text(
                'Account Number',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Gap.h12,
              TextFormField(
                controller: accountNumberController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                enabled: !withdrawalState.isLoading && selectedBank != null,
                decoration: InputDecoration(
                  hintText: 'Enter 10-digit account number',
                  prefixIcon: Icon(PhosphorIconsRegular.userCircle,
                      color: Colors.grey.shade600),
                  suffixIcon: accountNumberController.text.length == 10 &&
                          selectedBank != null
                      ? withdrawalState.validationResult.isLoading
                          ? Padding(
                              padding: EdgeInsets.all(12.w),
                              child: SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.blue),
                                ),
                              ),
                            )
                          : Builder(
                              builder: (context) {
                                final result = withdrawalState
                                    .validationResult.valueOrNull;
                                if (result != null &&
                                    result['success'] == true) {
                                  return Icon(PhosphorIconsFill.checkCircle,
                                      color: Colors.green.shade600,
                                      size: 24.sp);
                                } else if (result != null &&
                                    result['success'] == false) {
                                  return Icon(PhosphorIconsFill.warningCircle,
                                      color: Colors.red.shade600, size: 24.sp);
                                }
                                return SizedBox.shrink();
                              },
                            )
                      : null,
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
                  counterText: '',
                ),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) {
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  if (value.length < 10) {
                    return 'Account number must be 10 digits';
                  }
                  return null;
                },
              ),
              if (selectedBank == null)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    'Please select a bank first',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              Gap.h24,
              // Validation Result
              withdrawalState.validationResult.when(
                data: (result) {
                  if (result.isEmpty) {
                    return SizedBox.shrink();
                  }
                  final validated = result['success'] == true;
                  final accountName = result['data']?['account_name'] ?? '';
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color:
                          validated ? Colors.green.shade50 : Colors.red.shade50,
                      border: Border.all(
                        color: validated
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          validated ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.warningCircle,
                          color: validated
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                          size: 24.sp,
                        ),
                        Gap.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                validated
                                    ? 'Account Verified'
                                    : 'Validation Failed',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: validated
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                              if (validated && accountName.isNotEmpty) ...[
                                Gap.h4,
                                Text(
                                  'Account Name: $accountName',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade300),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.blue),
                        ),
                      ),
                      Gap.w12,
                      Text(
                        'Validating account...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (error, stack) => Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIconsRegular.warningCircle,
                          color: Colors.red.shade600, size: 24.sp),
                      Gap.w12,
                      Expanded(
                        child: Text(
                          'Error: ${error.toString()}',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Gap.h32,
              // Save Button
              Builder(
                builder: (context) {
                  final validationData =
                      withdrawalState.validationResult.valueOrNull;
                  final isValidated = validationData != null &&
                      validationData.isNotEmpty &&
                      validationData['success'] == true;
                  final accountName = isValidated
                      ? (validationData['data']?['account_name'] ?? 'Account')
                      : 'Account';

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (selectedBank == null ||
                              accountNumberController.text.isEmpty ||
                              !isValidated ||
                              withdrawalState.isLoading)
                          ? null
                          : () async {
                              final notifier =
                                  ref.read(withdrawalProvider.notifier);

                              if (withdrawalState.userBank.value != null) {
                                await notifier.updateBank(
                                  selectedBank!.code,
                                  accountNumberController.text,
                                  accountName,
                                  selectedBank!.name,
                                );
                              } else {
                                await notifier.createBank(
                                  selectedBank!.code,
                                  accountNumberController.text,
                                  accountName,
                                  selectedBank!.name,
                                );
                              }

                              if (mounted) {
                                Navigator.pop(context, true);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              withdrawalState.userBank.value != null
                                  ? 'Update Bank Account'
                                  : 'Save Bank Account',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
