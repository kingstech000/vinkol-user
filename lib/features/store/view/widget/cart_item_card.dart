import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:starter_codes/core/extensions/string_extension.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/widgets/gap.dart';

class CartItemCard extends StatelessWidget {
  final StoreProduct product;
  final Function(int) onQuantityChanged;
  final Function(StoreProduct)? onRemoveCompletely;

  const CartItemCard({
    super.key,
    required this.product,
    required this.onQuantityChanged,
    this.onRemoveCompletely,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total price based on product quantity
    final num totalPrice = product.price * (product.quantity ?? 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product.image.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Align children to the start (left)
                children: [
                  Row(
                    // This row contains the product title on the left
                    // and the prices column on the right
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          maxLines: 2, // Allow title to wrap if needed
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(
                          width: 8), // Space between title and prices
                      Column(
                        // Prices column, aligned to the end (right)
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppText.caption(
                            '${product.price.toString().toMoney()}/pc', // Unit price

                            color: Colors.grey[600],
                          ),
                          AppText.button(
                            totalPrice.toString().toMoney(),
                            color: AppColors.primary, // Blue color from image
                          ),
                        ],
                      ),
                    ],
                  ),
                  Gap.h8, // Vertical gap between title/price row and quantity/delete row
                  Row(
                    // This row contains the quantity controls and the delete icon
                    children: [
                      // Quantity selector container
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if ((product.quantity ?? 0) > 0) {
                                  onQuantityChanged(
                                      (product.quantity ?? 0) - 1);
                                } else {
                                  // Optional: If quantity goes to 0, completely remove the item
                                  onRemoveCompletely?.call(product);
                                }
                              },
                              child: const Icon(Icons.remove,
                                  size: 20, color: Colors.black),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '${product.quantity ?? 0}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => onQuantityChanged(
                                  (product.quantity ?? 0) + 1),
                              child: const Icon(Icons.add,
                                  size: 20, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Gap.w12, // Gap between quantity controls and delete icon
                      // Delete icon, only show if onRemoveCompletely is provided
                      if (onRemoveCompletely != null)
                        GestureDetector(
                          onTap: () => onRemoveCompletely!(product),
                          // Using a normal Icon and GestureDetector for consistent sizing with buttons
                          child: const Icon(Icons.delete_outline,
                              color: Colors.grey, size: 24),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
