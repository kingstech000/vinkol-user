import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_tag_model.dart';
import 'package:starter_codes/provider/store_provider.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/dot_spinning_indicator.dart';
import 'package:starter_codes/widgets/app_button.dart';

class TagsScreen extends ConsumerStatefulWidget {
  const TagsScreen({super.key});

  @override
  ConsumerState<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends ConsumerState<TagsScreen> {
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.h1(
                    'Shop by Category',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  Gap.h8,
                  AppText.body(
                    'Browse stores by category',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),

            // Tags Grid
            Expanded(
              child: ref.watch(storeTagsProvider).when(
                    data: (tags) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: GridView.builder(
                        padding: EdgeInsets.only(bottom: 20.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: tags.length,
                        itemBuilder: (context, index) {
                          final tag = tags[index];
                          return _buildTagCard(context, ref, tag);
                        },
                      ),
                    ),
                    loading: () => const Center(
                      child: DotSpinningIndicator(),
                    ),
                    error: (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.w,
                            color: Colors.red,
                          ),
                          Gap.h16,
                          AppText.body(
                            'Failed to load categories',
                            color: Colors.grey.shade600,
                            fontSize: 14.sp,
                          ),
                          Gap.h16,
                          AppButton.primary(
                            title: 'Retry',
                            onTap: () {
                              ref.invalidate(storeTagsProvider);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagCard(BuildContext context, WidgetRef ref, StoreTag tag) {
    return InkWell(
      onTap: () {
        ref.read(selectedTagProvider.notifier).state = tag.tagValue;
        NavigationService.instance.navigateTo(
          NavigatorRoutes.storesScreen,
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tag Image
            Container(
              width: 130.w,
              height: 130.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: tag.imageUrl,
                  fit: BoxFit.cover,
                  width: 130.w,
                  height: 130.h,
                  placeholder: (context, url) => Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    // Fallback icon if image not found
                    return Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        _getTagIcon(tag.tagValue),
                        size: 40.w,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ),
            Gap.h12,
            // Tag Name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                tag.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTagIcon(String tagValue) {
    switch (tagValue) {
      case 'supermarket':
        return Icons.shopping_cart;
      case 'beauty':
        return Icons.face;
      case 'fashion':
        return Icons.checkroom;
      case 'electronics':
        return Icons.devices;
      case 'food':
        return Icons.restaurant;
      case 'bakery':
        return Icons.cake;
      case 'pharmacy':
        return Icons.local_pharmacy;
      default:
        return Icons.store;
    }
  }
}
