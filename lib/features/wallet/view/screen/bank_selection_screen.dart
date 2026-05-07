import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/widgets/gap.dart';
import '../../model/bank_model.dart';
import '../../view_model/withdrawal_view_model.dart';

class BankSelectionScreen extends ConsumerStatefulWidget {
  const BankSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BankSelectionScreen> createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends ConsumerState<BankSelectionScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Bank> filteredBanks = [];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterBanks(String query, List<Bank> banks) {
    setState(() {
      if (query.isEmpty) {
        filteredBanks = banks;
      } else {
        filteredBanks = banks
            .where((bank) =>
                bank.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
          'Select Bank',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search bank...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
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
              onChanged: (value) {
                withdrawalState.bankList.whenData((banks) {
                  _filterBanks(value, banks);
                });
              },
            ),
          ),
          Expanded(
            child: withdrawalState.bankList.when(
              data: (banks) {
                final displayBanks = searchController.text.isEmpty ? banks : filteredBanks;
                if (displayBanks.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64.sp, color: Colors.grey.shade300),
                          Gap.h16,
                          Text(
                            'No banks found',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Gap.h8,
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: displayBanks.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final bank = displayBanks[index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 0),
                      title: Text(
                        bank.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        ref.read(withdrawalProvider.notifier).selectBank(bank);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: AppColors.blue),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                      Gap.h16,
                      Text(
                        'Error loading banks',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Gap.h8,
                      Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
