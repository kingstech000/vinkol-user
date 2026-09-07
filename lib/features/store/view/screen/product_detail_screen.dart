import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/shop_widgets.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// One product.
///
/// No stock status and no delivery estimate: the product record carries neither, and a
/// confident "in stock" the backend cannot support is worse than saying nothing. What the
/// screen does commit to is the price, who is selling it, and how many you are adding.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.product});

  final StoreProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final Store? store = ref.watch(currentStoreProvider);
    // Watched, not read: the stepper and the dock both have to move when the cart does.
    ref.watch(cartProvider);
    final int quantity =
        ref.read(cartProvider.notifier).getProductQuantity(product);
    final bool inCart = quantity > 0;
    final int lineQuantity = inCart ? quantity : 1;

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: AppBar(
        backgroundColor: v.canvas,
        surfaceTintColor: v.canvas,
        elevation: 0,
        title: Text(
          product.title,
          style: VinkolType.h3.copyWith(color: v.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  VinkolSpace.pageMargin,
                  VinkolSpace.sm,
                  VinkolSpace.pageMargin,
                  VinkolSpace.xxl,
                ),
                children: <Widget>[
                  ShopImageBlock(
                    imageUrl: product.image.imageUrl,
                    height: 210,
                    width: double.infinity,
                    radius: VinkolRadius.brLg,
                  ),
                  const SizedBox(height: VinkolSpace.xl),
                  if (product.category.isNotEmpty) ...<Widget>[
                    Text(
                      product.category,
                      style: VinkolType.labelS.copyWith(color: v.textTertiary),
                    ),
                    const SizedBox(height: VinkolSpace.sm),
                  ],
                  Text(
                    product.title,
                    style: VinkolType.h1.copyWith(color: v.textPrimary),
                  ),
                  const SizedBox(height: VinkolSpace.md),
                  Text(
                    MarketFormat.money(product.price),
                    style: VinkolType.numXl.copyWith(color: v.textPrimary),
                  ),
                  if (product.description?.isNotEmpty ?? false) ...<Widget>[
                    const SizedBox(height: VinkolSpace.lg),
                    Text(
                      product.description!,
                      style: VinkolType.bodyL.copyWith(color: v.textSecondary),
                    ),
                  ],
                  if (store != null) ...<Widget>[
                    VinkolSectionHeader(label: l10n.storeSoldBy),
                    VinkolRowGroup(
                      children: <VinkolRow>[
                        VinkolRow(
                          title: store.name ?? '',
                          meta: store.address ?? '',
                          icon: Icons.storefront_outlined,
                          metaMaxLines: 2,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                  ],
                  VinkolSectionHeader(label: l10n.storeQuantity),
                  Container(
                    padding: const EdgeInsets.all(VinkolSpace.md),
                    decoration: BoxDecoration(
                      color: v.surface,
                      borderRadius: VinkolRadius.brMd,
                      border: VinkolElevation.hairline(v),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            inCart ? l10n.storeInYourCart : l10n.storeHowMany,
                            style: VinkolType.body
                                .copyWith(color: v.textSecondary),
                          ),
                        ),
                        QuantityStepper(
                          quantity: lineQuantity,
                          onDecrement: () => ref
                              .read(cartProvider.notifier)
                              .removeProduct(product),
                          onIncrement: () => ref
                              .read(cartProvider.notifier)
                              .addProduct(product),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            VinkolDock(
              label: l10n.storeTimesPrice(
                  lineQuantity, MarketFormat.money(product.price)),
              value: MarketFormat.money(product.price * lineQuantity),
              actionLabel: inCart ? l10n.storeViewCart : l10n.storeAddToCart,
              onAction: () {
                if (inCart) {
                  NavigationService.instance
                      .navigateTo(NavigatorRoutes.cartScreen);
                } else {
                  ref.read(cartProvider.notifier).addProduct(product);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
