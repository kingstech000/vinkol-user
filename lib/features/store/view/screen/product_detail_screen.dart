import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/launch_link.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/store_header.dart';
import 'package:starter_codes/features/store/view/widget/store_ui.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

/// One product. The photo, then the four things a buyer wants in order:
/// what it is, what it costs, whether it is in stock, and who sells it. The
/// action stays pinned at the bottom whatever the description's length.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.product});

  final StoreProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(currentStoreProvider);
    final quantity = ref.watch(
      cartProvider.select((cart) =>
          cart.products
              .where((item) => item.id == product.id)
              .firstOrNull
              ?.quantity ??
          0),
    );
    final description = product.description?.trim();

    return Scaffold(
      backgroundColor: VinkolPalette.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Hero(product: product)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              VinkolSpace.pageMargin,
              VinkolSpace.xl,
              VinkolSpace.pageMargin,
              VinkolSpace.xxxl,
            ),
            sliver: SliverList.list(
              children: [
                if (product.category.trim().isNotEmpty) ...[
                  AppText.caption(
                    product.category.trim().replaceAll('-', ' ').toUpperCase(),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: VinkolPalette.neutral500,
                    letterSpacing: 0.6,
                  ),
                  Gap.h6,
                ],
                AppText.h1(
                  product.title,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: VinkolPalette.neutral900,
                  letterSpacing: -0.4,
                  lineHeight: 1.2,
                ),
                Gap.h12,
                _PriceRow(product: product),
                if (description != null && description.isNotEmpty) ...[
                  const Gap.h(VinkolSpace.sectionGap),
                  const _SectionLabel('About this item'),
                  Gap.h8,
                  AppText.body(
                    description,
                    fontSize: 15,
                    color: VinkolPalette.neutral700,
                    lineHeight: 1.5,
                  ),
                ],
                const Gap.h(VinkolSpace.sectionGap),
                const _SectionLabel('Sold by'),
                Gap.h8,
                _SellerCard(store: store),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ActionBar(product: product, quantity: quantity),
    );
  }
}

/// The photo, edge to edge, with the back control resting on it.
class _Hero extends StatelessWidget {
  const _Hero({required this.product});

  final StoreProduct product;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ProductImage(
            url: product.image.imageUrl,
            borderRadius: BorderRadius.zero,
            iconSize: 48,
          ),
        ),
        PositionedDirectional(
          top: MediaQuery.paddingOf(context).top + VinkolSpace.sm,
          start: VinkolSpace.pageMargin,
          child: CircleIconButton(
            icon: PhosphorIconsRegular.caretLeft,
            label: 'Back',
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }
}

/// Price, then stock. Stock is a word, not a colour: "In stock", "Only 3
/// left", "Out of stock".
class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product});

  final StoreProduct product;

  @override
  Widget build(BuildContext context) {
    final stock = product.inventory;
    final String note;
    final Color noteColor;
    if (!product.inStock) {
      note = 'Out of stock';
      noteColor = VinkolPalette.neutral500;
    } else if (stock != null && stock <= 5) {
      note = 'Only $stock left';
      noteColor = VinkolPalette.warningText;
    } else {
      note = 'In stock';
      noteColor = VinkolPalette.successText;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        PriceText.large(product.unitPrice),
        Gap.w12,
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: AppText.caption(
            note,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: noteColor,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppText.h4(
      text,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: VinkolPalette.neutral900,
    );
  }
}

/// The store, and a way to reach it. The whole store is one tap away already
/// (it is the screen underneath), so this is information, not navigation.
class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.store});

  final Store? store;

  @override
  Widget build(BuildContext context) {
    final phone = store?.phone?.trim();

    return Container(
      padding: const EdgeInsets.all(VinkolSpace.lg),
      decoration: BoxDecoration(
        color: VinkolPalette.white,
        borderRadius: VinkolRadius.brMd,
        border: Border.all(color: VinkolPalette.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (store == null)
            const StoreHeaderSkeleton()
          else
            StoreHeader(store: store!, dense: true),
          if (phone != null && phone.isNotEmpty) ...[
            Gap.h12,
            const Divider(height: 1, color: VinkolPalette.neutral100),
            Gap.h12,
            _CallRow(phone: phone),
          ],
        ],
      ),
    );
  }
}

class _CallRow extends StatelessWidget {
  const _CallRow({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Call store, $phone',
      child: InkWell(
        onTap: () => makePhoneCall(phone),
        borderRadius: VinkolRadius.brSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: VinkolSpace.xs),
          child: Row(
            children: [
              const Icon(
                PhosphorIconsRegular.phone,
                size: 18,
                color: VinkolPalette.brand600,
              ),
              Gap.w10,
              Expanded(
                child: AppText.body(
                  phone,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: VinkolPalette.neutral900,
                ),
              ),
              AppText.caption(
                'Call',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: VinkolPalette.brand600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pinned to the bottom. Three shapes: add; adjust and go to the cart; or,
/// when the store cannot sell it, a plain statement of why there is no
/// button rather than a greyed-out one.
class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.product, required this.quantity});

  final StoreProduct product;
  final int quantity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    final stock = product.inventory;
    final atLimit = stock != null && quantity >= stock;

    final Widget content;
    if (!product.inStock) {
      content = Row(
        children: [
          const Icon(
            PhosphorIconsRegular.prohibit,
            size: 18,
            color: VinkolPalette.neutral500,
          ),
          Gap.w8,
          Expanded(
            child: AppText.body(
              'Out of stock — check back later.',
              fontSize: 14,
              color: VinkolPalette.neutral600,
            ),
          ),
        ],
      );
    } else if (quantity == 0) {
      content = AppButton.primary(
        title: 'Add to cart',
        onTap: () {
          HapticFeedback.lightImpact();
          cart.addProduct(product);
        },
      );
    } else {
      content = Row(
        children: [
          QuantityStepper(
            quantity: quantity,
            canIncrement: !atLimit,
            onIncrement: () => cart.addProduct(product),
            onDecrement: () => cart.removeProduct(product),
          ),
          Gap.w12,
          Expanded(
            child: AppButton.primary(
              title: 'View cart',
              onTap: () => NavigationService.instance.navigateTo(
                NavigatorRoutes.cartScreen,
                argument: {'isFromWebviewClosing': false},
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: VinkolPalette.white,
        border: Border(top: BorderSide(color: VinkolPalette.neutral100)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            VinkolSpace.pageMargin,
            VinkolSpace.md,
            VinkolSpace.pageMargin,
            VinkolSpace.md,
          ),
          child: content,
        ),
      ),
    );
  }
}
