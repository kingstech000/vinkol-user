import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/store_ui.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/widgets/gap.dart';

/// A product in the grid. Photo, name, price, and the one action — add, or
/// adjust what is already in the basket. Tapping anywhere else opens the
/// detail page.
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product});

  final StoreProduct product;

  /// Grid cell proportions: a square photo plus ~92pt of text and control.
  static const aspectRatio = 0.62;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(
      cartProvider.select((cart) =>
          cart.products
              .where((item) => item.id == product.id)
              .firstOrNull
              ?.quantity ??
          0),
    );
    final cart = ref.read(cartProvider.notifier);
    final inStock = product.inStock;
    final stock = product.inventory;
    final atLimit = stock != null && quantity >= stock;

    return Semantics(
      button: true,
      label: '${product.title}, ${product.unitPrice.format()}'
          '${inStock ? '' : ', out of stock'}',
      child: Material(
        color: VinkolPalette.white,
        shape: const RoundedRectangleBorder(
          borderRadius: VinkolRadius.brMd,
          side: BorderSide(color: VinkolPalette.neutral200),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => NavigationService.instance.navigateTo(
            NavigatorRoutes.productDetailScreen,
            argument: {'product': product},
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductImage(
                      url: product.image.imageUrl,
                      borderRadius: BorderRadius.zero,
                    ),
                    if (!inStock)
                      const _StockBanner(label: 'Out of stock')
                    else if (stock != null && stock <= 5)
                      _StockBanner(label: 'Only $stock left'),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    VinkolSpace.md,
                    VinkolSpace.sm + 2,
                    VinkolSpace.md,
                    VinkolSpace.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Two lines reserved, so the price sits on the same
                      // baseline in every tile of a row.
                      SizedBox(
                        height: 38,
                        child: AppText.body(
                          product.title,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: inStock
                              ? VinkolPalette.neutral900
                              : VinkolPalette.neutral500,
                          maxLines: 2,
                          lineHeight: 1.3,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: PriceText.small(product.unitPrice),
                          ),
                          Gap.w8,
                          if (!inStock)
                            const SizedBox.shrink()
                          else if (quantity == 0)
                            _AddButton(onTap: () => cart.addProduct(product))
                          else
                            QuantityStepper(
                              compact: true,
                              quantity: quantity,
                              canIncrement: !atLimit,
                              onIncrement: () => cart.addProduct(product),
                              onDecrement: () => cart.removeProduct(product),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The add control at rest: a filled 44×36 block with a plus. Small enough
/// to leave the price as the loudest thing on the tile.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add to cart',
      child: Material(
        color: VinkolPalette.brand500,
        borderRadius: VinkolRadius.brSm,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox(
            width: 44,
            height: 36,
            child: Icon(
              PhosphorIconsBold.plus,
              size: 16,
              color: VinkolPalette.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// A word across the bottom of the photo. Text on a solid strip, never a
/// colour wash — it has to read on any photo and in grayscale.
class _StockBanner extends StatelessWidget {
  const _StockBanner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: Container(
        margin: const EdgeInsets.all(VinkolSpace.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: VinkolSpace.sm,
          vertical: VinkolSpace.xs,
        ),
        decoration: const BoxDecoration(
          color: VinkolPalette.neutral900,
          borderRadius: VinkolRadius.brXs,
        ),
        child: AppText.caption(
          label,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: VinkolPalette.white,
        ),
      ),
    );
  }
}

/// The tile's silhouette while products load.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VinkolPalette.white,
        borderRadius: VinkolRadius.brMd,
        border: Border.all(color: VinkolPalette.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(
            aspectRatio: 1,
            child: SkeletonBox(borderRadius: BorderRadius.zero),
          ),
          Padding(
            padding: const EdgeInsets.all(VinkolSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: double.infinity, height: 14),
                Gap.h6,
                const SkeletonBox(width: 80, height: 14),
                Gap.h12,
                const SkeletonBox(width: 56, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
