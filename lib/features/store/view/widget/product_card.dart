import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/extensions/extensions.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';

class ProductCard extends ConsumerWidget {
  final StoreProduct product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentQuantity =
        ref.watch(cartProvider.notifier).getProductQuantity(product);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: product.image.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[50],
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[100],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: AppText.free(
                      product.title,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Colors.black87,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.price.toString().toMoney(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced from 8 to 4
                  SizedBox(
                    height: 28, // Reduced from 32 to 28
                    child: currentQuantity == 0
                        ? AppButton.primary(
                            onTap: () {
                              // Allow adding to cart - auth check will be done at payment
                              ref
                                  .read(cartProvider.notifier)
                                  .addProduct(product);
                            },
                            title: 'Add To Cart',
                          )
                        : _buildQuantityControls(context, ref, currentQuantity),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(
      BuildContext context, WidgetRef ref, int currentQuantity) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Decrease Button
          Expanded(
            child: InkWell(
              onTap: () {
                ref.read(cartProvider.notifier).removeProduct(product);
              },
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: Container(
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Icon(
                  Icons.remove,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ),
          ),

          // Quantity Display
          Container(
            width: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Center(
                child: Text(
                  currentQuantity.toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            color: Colors.grey[300],
          ),

          // Increase Button
          Expanded(
            child: InkWell(
              onTap: () {
                // Allow increasing quantity - auth check will be done at payment
                ref.read(cartProvider.notifier).addProduct(product);
              },
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: Container(
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
