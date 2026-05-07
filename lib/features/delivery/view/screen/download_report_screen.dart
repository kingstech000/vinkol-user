import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/delivery/view_model/delivery_view_model.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DownloadReportScreen extends ConsumerStatefulWidget {
  const DownloadReportScreen({super.key});

  @override
  ConsumerState<DownloadReportScreen> createState() => _DownloadReportScreenState();
}

class _DownloadReportScreenState extends ConsumerState<DownloadReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Ensure end date is not before start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _handleDownload() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Please select both start and end dates.')),
      );
      return;
    }

    final dateFormat = DateFormat('yyyy-MM-dd');
    final startDateStr = dateFormat.format(_startDate!);
    final endDateStr = dateFormat.format(_endDate!);

    // The ViewModel now handles its own state (busy/idle/error) 
    // and triggers the appropriate dialogs via DialogService.
    await ref.read(deliveryViewModelProvider).downloadReport(startDateStr, endDateStr);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: AppColors.red,
                  size: 64.w,
                ),
              ),
              Gap.h24,
              AppText.h2(
                'Request Failed',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              Gap.h16,
              AppText.body(
                message,
                centered: true,
                color: Colors.grey[600],
              ),
              Gap.h32,
              AppButton.primary(
                title: 'Try Again',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.green,
                  size: 64.w,
                ),
              ),
              Gap.h24,
              AppText.h2(
                'Success!',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              Gap.h16,
              AppText.body(
                'Your order report has been generated successfully and sent to your registered email address.',
                centered: true,
                color: Colors.grey[600],
              ),
              Gap.h32,
              AppButton.primary(
                title: 'Done',
                onTap: () {
                  Navigator.of(context).pop(true); // Close dialog and pass success
                },
              ),
            ],
          ),
        ),
      ),
    ).then((value) {
      if (value == true && mounted) {
        Navigator.of(context).pop(); // Close screen after dialog closes
      }
    });
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.grey[50],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.caption(
                  label,
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                Gap.h4,
                AppText.body(
                  date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Select Date',
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            Icon(Icons.calendar_today, color: AppColors.primary, size: 20.w),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppText.h2(
          'Download Report',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.blue, size: 24.w),
                    Gap.w12,
                    Expanded(
                      child: AppText.body(
                        'The generated report will be sent directly to your registered email address.',
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1),
              Gap.h32,
              AppText.h2(
                'Select Date Range',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
              Gap.h16,
              _buildDatePickerField(
                label: 'Start Date',
                date: _startDate,
                onTap: () => _selectDate(context, true),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              Gap.h16,
              _buildDatePickerField(
                label: 'End Date',
                date: _endDate,
                onTap: () => _selectDate(context, false),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              const Spacer(),
              AppButton.primary(
                title: 'Download Report',
                loading: ref.watch(deliveryViewModelProvider).isBusy,
                onTap: _handleDownload,
              ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),
              Gap.h12,
            ],
          ),
        ),
      ),
    );
  }
}
