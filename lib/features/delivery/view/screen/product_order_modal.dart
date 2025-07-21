// lib/features/delivery/widgets/products_ordered_modal.dart (or wherever you prefer)
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/extensions/double_extension.dart'; // Make sure this path is correct
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart'; // Make sure this path is correct
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';

class ProductsOrderedModal extends StatelessWidget {
  final List<ProductModel> products;

  const ProductsOrderedModal({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiniAppBar(title: 'Cart',),
      body: products.isEmpty
          ? Center(
              child: AppText.body('No products found for this order.',
                  fontSize: 16.sp),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  elevation: 2
                  ,color: AppColors.white,
                  margin: EdgeInsets.only(bottom: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image (if available)
                        if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                          Container(
                            width: 60.w,
                            height: 60.w,
                            margin: EdgeInsets.only(right: 12.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: AppColors.greyLight,
                              image: DecorationImage(
                                image: NetworkImage(product.imageUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 60.w,
                            height: 60.w,
                            margin: EdgeInsets.only(right: 12.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: AppColors.white,
                            ),
                            child: Icon(Icons.image_not_supported, size: 30.w, color: AppColors.greyLight),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.button(
                                product.title ?? 'Unknown Product',
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Gap.h4,
                              AppText.caption(
                                'Quantity: ${product.quantity ?? 0}',
                              
                                fontSize: 14.sp,
                              ),
                              Gap.h4,
                              AppText.button(
                                (product.price ?? 0.0).toMoney(),
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}