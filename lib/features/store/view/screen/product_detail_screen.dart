import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:starter_codes/core/extensions/extensions.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final StoreProduct product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final store = ref.watch(currentStoreProvider);
    ref.watch(cartProvider);
    final int currentQuantity =
        ref.read(cartProvider.notifier).getProductQuantity(widget.product);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 350.h,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  color: Colors.black87,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: CachedNetworkImage(
                  imageUrl: widget.product.image.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Info Section
                  Container(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: AppText.caption(
                            widget.product.category.toUpperCase(),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Gap.h12,

                        // Product Title
                        AppText.h1(
                          widget.product.title,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        Gap.h16,

                        // Price Section
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.primary.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            children: [
                              AppText.h1(
                                widget.product.price.toString().toMoney(),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        Gap.h24,

                        // Description Section
                        if (widget.product.description != null &&
                            widget.product.description!.isNotEmpty) ...[
                          AppText.h3(
                            'Description',
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                          Gap.h12,
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: AppText.body(
                              widget.product.description!,
                              fontSize: 15,
                              color: Colors.grey[700],
                              height: 1.6,
                            ),
                          ),
                          Gap.h24,
                        ],

                        // Store Info Section
                        if (store != null) ...[
                          AppText.h3(
                            'Store Information',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          Gap.h16,
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Store Header
                                Row(
                                  children: [
                                    // Store Avatar
                                    Container(
                                      width: 60.w,
                                      height: 60.w,
                                      decoration: BoxDecoration(
                                        color: Colors.orange[50],
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.orange[200]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: store.avatar?.imageUrl != null
                                          ? ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    store.avatar!.imageUrl,
                                                fit: BoxFit.cover,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                  Icons.store_rounded,
                                                  color: Colors.orange[400],
                                                  size: 30.w,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.store_rounded,
                                              color: Colors.orange[400],
                                              size: 30.w,
                                            ),
                                    ),
                                    Gap.w16,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AppText.h3(
                                            store.name ?? 'Store Name',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          Gap.h4,
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 4.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: store.isOpen
                                                      ? Colors.green[50]
                                                      : Colors.red[50],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 6.w,
                                                      height: 6.w,
                                                      decoration: BoxDecoration(
                                                        color: store.isOpen
                                                            ? Colors.green[500]
                                                            : Colors.red[500],
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    Gap.w(4),
                                                    AppText.caption(
                                                      store.isOpen
                                                          ? 'Open'
                                                          : 'Closed',
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: store.isOpen
                                                          ? Colors.green[700]
                                                          : Colors.red[700],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Gap.h20,

                                // Store Details
                                if (store.address != null) ...[
                                  _buildStoreDetailItem(
                                    icon: Icons.location_on_rounded,
                                    label: 'Address',
                                    value: store.address!,
                                  ),
                                  Gap.h12,
                                ],
                                if (store.phone != null) ...[
                                  _buildStoreDetailItem(
                                    icon: Icons.phone_rounded,
                                    label: 'Phone',
                                    value: store.phone!,
                                  ),
                                  Gap.h12,
                                ],
                                if (store.state != null) ...[
                                  _buildStoreDetailItem(
                                    icon: Icons.map_rounded,
                                    label: 'State',
                                    value: store.state!,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Gap.h24,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        constraints: BoxConstraints(
          maxHeight: 100.h,
        ),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: currentQuantity == 0
            ? AppButton.primary(
                onTap: () {
                  // Haptic feedback
                  HapticFeedback.lightImpact();
                  // Add to cart
                  ref.read(cartProvider.notifier).addProduct(widget.product);
                  // Show success feedback
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20.w,
                            ),
                            Gap.w12,
                            Expanded(
                              child: AppText.body(
                                '${widget.product.title} added to cart',
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green[600],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            topRight: Radius.circular(12.r),
                          ),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                title: 'Add To Cart',
              )
            : _buildQuantityControls(currentQuantity),
      ),
    );
  }

  Widget _buildStoreDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 18.w,
            color: Colors.grey[700],
          ),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.caption(
                label,
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
              Gap.h(4),
              AppText.body(
                value,
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(int currentQuantity) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Decrease Button
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final previousQuantity = currentQuantity;
                  ref.read(cartProvider.notifier).removeProduct(widget.product);
                  // Show feedback if item was removed completely
                  if (previousQuantity == 1 && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.remove_shopping_cart,
                              color: Colors.white,
                              size: 20.w,
                            ),
                            Gap.w12,
                            Expanded(
                              child: AppText.body(
                                '${widget.product.title} removed from cart',
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.orange[600],
                        behavior: SnackBarBehavior.fixed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            topRight: Radius.circular(12.r),
                          ),
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  bottomLeft: Radius.circular(14.r),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // Quantity Display
          Container(
            width: 1,
            color: AppColors.primary,
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.primary.withOpacity(0.05),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: AppText.h2(
                  currentQuantity.toString(),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            color: AppColors.primary,
          ),

          // Increase Button
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(cartProvider.notifier).addProduct(widget.product);
                },
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(14.r),
                  bottomRight: Radius.circular(14.r),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.primary,
                    size: 24,
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
