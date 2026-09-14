import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/money/money.dart';

/// A price in its own market. The number is the hero: tabular figures at
/// full weight, the currency symbol a step lighter (signature #4).
class PriceText extends StatelessWidget {
  const PriceText(
    this.money, {
    super.key,
    this.size = 15,
    this.weight = FontWeight.w600,
    this.color = VinkolPalette.neutral900,
    this.symbolColor = VinkolPalette.neutral500,
    this.prefix,
  });

  /// Compact: product tiles and cart rows.
  const PriceText.small(this.money, {super.key, this.prefix})
      : size = 14,
        weight = FontWeight.w600,
        color = VinkolPalette.neutral900,
        symbolColor = VinkolPalette.neutral500;

  /// The one big number on a screen: the product price, the order total.
  const PriceText.large(this.money, {super.key, this.prefix})
      : size = 24,
        weight = FontWeight.w700,
        color = VinkolPalette.neutral900,
        symbolColor = VinkolPalette.neutral500;

  final Money money;
  final double size;
  final FontWeight weight;
  final Color color;
  final Color symbolColor;

  /// A sign set in front of the symbol — `+` for money in, `−` for money
  /// out on a ledger. Drawn at the number's weight so it reads as part of it.
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    final symbol = money.currency.symbol;
    return Text.rich(
      TextSpan(
        children: [
          if (prefix != null)
            TextSpan(
              text: prefix,
              style: TextStyle(
                fontSize: size,
                fontWeight: weight,
                color: color,
              ),
            ),
          TextSpan(
            text: symbol,
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.w500,
              color: symbolColor,
            ),
          ),
          TextSpan(
            text: money.format(showSymbol: false),
            style: TextStyle(
              fontSize: size,
              fontWeight: weight,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      semanticsLabel: '${prefix ?? ''}${money.format()}',
    );
  }
}
