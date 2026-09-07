import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/store/model/store_tag_model.dart';
import 'package:starter_codes/features/store/view/widget/shop_widgets.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/provider/store_provider.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// The entry point to shopping: browse stores by category.
///
/// The first of four browse steps — categories, stores, products, product. Each one narrows,
/// and none of them promises anything the API cannot answer: there are no ratings here, no
/// distances and no delivery estimates, because StoreModel has none of those fields.
class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final AsyncValue<List<StoreTag>> tags = ref.watch(storeTagsProvider);
    final int cartCount = ref.watch(cartProvider.select((CartState c) => c
        .products
        .fold<int>(0, (int sum, item) => sum + (item.quantity ?? 0))));

    return Scaffold(
      backgroundColor: v.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                VinkolSpace.pageMargin,
                VinkolSpace.lg,
                VinkolSpace.pageMargin,
                VinkolSpace.lg,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(l10n.storeShop,
                            style:
                                VinkolType.h1.copyWith(color: v.textPrimary)),
                        const SizedBox(height: VinkolSpace.xs),
                        Text(l10n.storeBrowseStoresByCategory,
                            style: VinkolType.bodyS
                                .copyWith(color: v.textTertiary)),
                      ],
                    ),
                  ),
                  _CartButton(count: cartCount),
                ],
              ),
            ),
            Expanded(
              child: tags.when(
                loading: () => const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: VinkolSpace.pageMargin),
                  child: VinkolSkeletonList(count: 6),
                ),
                error: (Object error, StackTrace stack) =>
                    VinkolStateView.error(
                  title: l10n.storeFailedToLoadCategories,
                  message: error.toString(),
                  action: VinkolStateAction(
                    label: l10n.commonTryAgain,
                    onPressed: () => ref.invalidate(storeTagsProvider),
                  ),
                ),
                data: (List<StoreTag> items) {
                  if (items.isEmpty) {
                    return VinkolStateView.empty(
                      icon: Icons.category_outlined,
                      title: l10n.storeNoCategoriesYet,
                      message: l10n.storeNoCategoriesYetBody,
                      action: VinkolStateAction(
                        label: l10n.commonTryAgain,
                        onPressed: () => ref.invalidate(storeTagsProvider),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      VinkolSpace.pageMargin,
                      0,
                      VinkolSpace.pageMargin,
                      VinkolPod.bodyInsetOf(context),
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: VinkolSpace.md,
                      mainAxisSpacing: VinkolSpace.md,
                      // Tall enough for a two-line category name at a 1.3x text scale.
                      mainAxisExtent: 132,
                    ),
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _CategoryTile(tag: items[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.tag});

  final StoreTag tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ref.read(selectedTagProvider.notifier).state = tag.tagValue;
          NavigationService.instance.navigateTo(NavigatorRoutes.storesScreen);
        },
        child: Container(
          padding: const EdgeInsets.all(VinkolSpace.cardPadding),
          decoration: BoxDecoration(
            color: v.surface,
            borderRadius: VinkolRadius.brMd,
            border: VinkolElevation.hairline(v),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ShopImageBlock(
                imageUrl: tag.imageUrl,
                width: 42,
                height: 42,
                icon: Icons.storefront_outlined,
              ),
              const Spacer(),
              Text(
                tag.name,
                style: VinkolType.h4.copyWith(color: v.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The cart, reachable from every browse screen. The count is the point — a cart icon that
/// does not say how much is in it makes the user open it to find out.
class _CartButton extends StatelessWidget {
  const _CartButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Semantics(
      button: true,
      label: context.l10n.storeInCart(count),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            NavigationService.instance.navigateTo(NavigatorRoutes.cartScreen),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(Icons.shopping_bag_outlined, size: 22, color: v.textPrimary),
              if (count > 0)
                PositionedDirectional(
                  top: 2,
                  end: 2,
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: v.brand,
                      borderRadius: VinkolRadius.brFull,
                    ),
                    child: Text(
                      '$count',
                      style: VinkolType.labelS.copyWith(color: v.onBrand),
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
