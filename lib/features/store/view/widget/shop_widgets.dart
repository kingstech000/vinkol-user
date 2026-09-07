import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/l10n/l10n.dart';

/// Product and store imagery, or the block that stands in for it.
///
/// There is no asset library and most catalogue rows carry no photograph, so the fallback is
/// a neutral well with an icon rather than a broken frame or a stretched placeholder image.
/// It is the same block at every size, which is what keeps a half-populated grid from looking
/// broken rather than merely sparse.
class ShopImageBlock extends StatelessWidget {
  const ShopImageBlock({
    super.key,
    this.imageUrl,
    this.height,
    this.width,
    this.icon = Icons.inventory_2_outlined,
    this.radius = VinkolRadius.brSm,
  });

  final String? imageUrl;
  final double? height;
  final double? width;
  final IconData icon;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    final Widget fallback = DecoratedBox(
      decoration: BoxDecoration(
        color: v.surfaceAlt,
        borderRadius: radius,
        border: Border.fromBorderSide(BorderSide(color: v.borderSubtle)),
      ),
      child: Center(
        child: Icon(icon, size: 22, color: v.textTertiary),
      ),
    );

    return SizedBox(
      height: height,
      width: width,
      child: imageUrl == null || imageUrl!.isEmpty
          ? fallback
          : ClipRRect(
              borderRadius: radius,
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                width: width,
                height: height,
                placeholder: (BuildContext context, String url) => fallback,
                errorWidget: (BuildContext context, String url, Object error) =>
                    fallback,
              ),
            ),
    );
  }
}

/// Whether a store is trading right now.
///
/// A separate axis from order status, so it does not borrow [VinkolStatusChip]'s closed set —
/// but it obeys the same rule (D-05): label first, then shape, then colour. Open is a filled
/// dot, closed is a hollow ring, and the words say which even in greyscale.
///
/// `isClosed` and `isOpenToday()` are the only trading fields StoreModel has. There is no
/// rating, no distance and no prep time, so none of those appear anywhere in this section.
class StoreOpenChip extends StatelessWidget {
  const StoreOpenChip({super.key, required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final Color ink = isOpen ? v.success : v.textTertiary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOpen ? ink : Colors.transparent,
            border: Border.fromBorderSide(BorderSide(color: ink, width: 1.5)),
            borderRadius: VinkolRadius.brFull,
          ),
        ),
        const SizedBox(width: VinkolSpace.sm),
        Text(
          isOpen ? context.l10n.storeOpen : context.l10n.storeClosed,
          style: VinkolType.labelS.copyWith(color: ink),
        ),
      ],
    );
  }
}

/// Quantity, as a stepper rather than a text field.
///
/// Cart quantities are single digits almost always, and a keyboard for "2" is a tax. Both
/// controls are 44pt; the count between them is tabular so the row does not reflow as it
/// changes from 9 to 10.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;

  /// At a quantity of one this is what removes the line, so it is never disabled.
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Container(
      padding: const EdgeInsets.all(VinkolSpace.xs),
      decoration: BoxDecoration(
        color: v.surfaceAlt,
        borderRadius: VinkolRadius.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _StepperButton(
            icon: quantity > 1 ? Icons.remove : Icons.delete_outline,
            semanticLabel: quantity > 1
                ? context.l10n.storeFewer
                : context.l10n.storeRemoveItem,
            onPressed: onDecrement,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: VinkolSpace.iconToLabel),
            child: Text(
              '$quantity',
              style: VinkolType.num.copyWith(color: v.textPrimary),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            semanticLabel: context.l10n.storeMore,
            accent: true,
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.accent = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        // 44pt of hit area around a 30pt painted control: the target is comfortable without
        // the stepper growing to 88pt wide.
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: accent ? v.brand : v.surfaceStrong,
                borderRadius: VinkolRadius.brFull,
              ),
              child: Icon(
                icon,
                size: 15,
                color: accent ? v.onBrand : v.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One product in the catalogue grid.
class ShopProductTile extends StatelessWidget {
  const ShopProductTile({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.onTap,
    required this.onAdd,
    this.quantityInCart = 0,
  });

  final String title;
  final num price;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  /// Non-zero swaps the add button for the count already in the cart.
  final int quantityInCart;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(VinkolSpace.sm),
          decoration: BoxDecoration(
            color: v.surface,
            borderRadius: VinkolRadius.brMd,
            border: VinkolElevation.hairline(v),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ShopImageBlock(
                  imageUrl: imageUrl,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: VinkolSpace.sm),
              Text(
                title,
                style: VinkolType.h4.copyWith(color: v.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: VinkolSpace.sm),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      MarketFormat.money(price),
                      style: VinkolType.num.copyWith(
                        color: v.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: VinkolSpace.sm),
                  _AddButton(quantityInCart: quantityInCart, onAdd: onAdd),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.quantityInCart, required this.onAdd});

  final int quantityInCart;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final bool inCart = quantityInCart > 0;

    return Semantics(
      button: true,
      label: inCart
          ? context.l10n.storeInCart(quantityInCart)
          : context.l10n.storeAddToCart,
      child: GestureDetector(
        onTap: onAdd,
        behavior: HitTestBehavior.opaque,
        // 44pt of hit area around a 30pt painted control. Missing this button opens the
        // product instead of adding it, so the target has to be forgiving.
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              padding: const EdgeInsets.symmetric(horizontal: VinkolSpace.sm),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: v.brand,
                borderRadius: VinkolRadius.brFull,
              ),
              child: inCart
                  ? Text(
                      '$quantityInCart',
                      style: VinkolType.label.copyWith(color: v.onBrand),
                    )
                  : Icon(Icons.add, size: 16, color: v.onBrand),
            ),
          ),
        ),
      ),
    );
  }
}
