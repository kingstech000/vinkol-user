import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/store_ui.dart';
import 'package:starter_codes/widgets/gap.dart';

/// One line of the basket. Photo, name, unit price, the stepper, and the
/// line total flush on the end so every total in the list shares one axis.
/// Not a card: rows are separated by hairlines so six of them fit a phone.
class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.product,
    required this.onIncrement,
    required this.onDecrement,
  });

  final StoreProduct product;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final quantity = product.quantity ?? 0;
    final lineTotal = product.unitPrice * quantity;
    final stock = product.inventory;
    final atLimit = stock != null && quantity >= stock;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VinkolSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: ProductImage(url: product.image.imageUrl, iconSize: 22),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.body(
                  product.title,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: VinkolPalette.neutral900,
                  maxLines: 2,
                  lineHeight: 1.3,
                ),
                Gap.h4,
                Row(
                  children: [
                    PriceText(
                      product.unitPrice,
                      size: 13,
                      weight: FontWeight.w500,
                      color: VinkolPalette.neutral500,
                      symbolColor: VinkolPalette.neutral400,
                    ),
                    AppText.caption(
                      ' each',
                      fontSize: 13,
                      color: VinkolPalette.neutral500,
                    ),
                  ],
                ),
                Gap.h10,
                Row(
                  children: [
                    QuantityStepper(
                      compact: true,
                      quantity: quantity,
                      canIncrement: !atLimit,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                    ),
                    const Spacer(),
                    PriceText(lineTotal, size: 15, weight: FontWeight.w600),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
