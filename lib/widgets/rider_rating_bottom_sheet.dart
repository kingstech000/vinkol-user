import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/delivery/data/delivery_service.dart';
import 'package:starter_codes/features/delivery/model/rider_rating_model.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

class RiderRatingBottomSheet extends ConsumerStatefulWidget {
  final String riderId;
  final String riderName;

  const RiderRatingBottomSheet({
    super.key,
    required this.riderId,
    required this.riderName,
  });

  static void show(
    BuildContext context, {
    required String riderId,
    required String riderName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RiderRatingBottomSheet(
        riderId: riderId,
        riderName: riderName,
      ),
    );
  }

  @override
  ConsumerState<RiderRatingBottomSheet> createState() =>
      _RiderRatingBottomSheetState();
}

class _RiderRatingBottomSheetState
    extends ConsumerState<RiderRatingBottomSheet> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _updateRating(int rating) {
    setState(() {
      _selectedRating = rating;
    });
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final deliveryService = ref.read(deliveryServiceProvider);
      final ratingRequest = RiderRatingRequest(
        rider: widget.riderId,
        starRating: _selectedRating,
        comment: _commentController.text.trim(),
      );

      await deliveryService.submitRiderRating(ratingRequest);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Rating submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the rating display
        ref.invalidate(riderRatingProvider(widget.riderId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit rating: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppText.h4(
                      'Rate Your Rider',
                      fontWeight: FontWeight.bold,
                      fontSize: 22.sp,
                    ),
                    Gap.h8,
                    AppText.body(
                      widget.riderName,
                      color: Colors.grey.shade600,
                      fontSize: 16.sp,
                    ),
                    Gap.h32,

                    // Swipeable Star Rating
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          // Calculate rating based on drag position
                          // Each star is approximately 60 pixels wide (48.w + 4.w margin on each side)
                          final starWidth = 60.w;
                          final startX =
                              (MediaQuery.of(context).size.width / 2) -
                                  (2.5 * starWidth);
                          final currentX = details.globalPosition.dx;
                          final relativeX = currentX - startX;
                          final newRating = ((relativeX / starWidth) + 0.5)
                              .clamp(0, 5)
                              .round();
                          if (newRating != _selectedRating &&
                              newRating >= 0 &&
                              newRating <= 5) {
                            _selectedRating = newRating;
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => GestureDetector(
                            onTap: () => _updateRating(index + 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Icon(
                                index < _selectedRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 48.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Gap.h16,
                    if (_selectedRating > 0)
                      AppText.body(
                        _getRatingText(_selectedRating),
                        color: AppColors.primary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    Gap.h32,

                    // Comment field
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Share your experience (optional)',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(16.w),
                      ),
                    ),
                    Gap.h32,

                    // Submit button
                    AppButton.primary(
                      title: _isSubmitting ? 'Submitting...' : 'Submit Rating',
                      onTap: _isSubmitting ? null : _submitRating,
                      loading: _isSubmitting,
                    ),
                    Gap.h24,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
