import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/extensions/extensions.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

class ProductCard extends ConsumerWidget {
  final StoreProduct product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentQuantity = ref.watch(cartProvider.notifier).getProductQuantity(product);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5, // Keep this flex for image for good proportion
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: product.image.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),

          Flexible( // Changed from Expanded to Flexible
            flex: 4, // Keep the flex proportion
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end, // Align contents to the bottom
                children: [
                  AppText.free(
                    product.title,
                  
                      fontWeight: FontWeight.bold,
                      fontSize: 10, // Slightly reduced font size for title
                      color: Colors.black,
                  
                  
                    // overflow: TextOverflow.ellipsis,
                  ),
                
  
                  Gap.h8,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      product.price.toString().toMoney(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15, // Slightly reduced font size for price
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Gap.h8,
                  if (currentQuantity == 0)...[
                      AppButton.primary(
                        onTap: () {
                          ref.read(cartProvider.notifier).addProduct(product);
                        },
                    
                    title: 'Add To Cart',
                        ),]
                      
                  
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            ref.read(cartProvider.notifier).removeProduct(product);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.remove, color: Colors.white, size: 18),
                          ),
                        ),
                        Text(
                          currentQuantity.toString(),
                          style: const TextStyle(
                            fontSize: 15, // Slightly reduced font size for quantity
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            ref.read(cartProvider.notifier).addProduct(product);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}