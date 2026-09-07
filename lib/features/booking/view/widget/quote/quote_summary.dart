import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/core/market/models.dart';
import 'package:starter_codes/features/booking/view/widget/stops/multistop_widgets.dart';
import 'package:starter_codes/l10n/l10n.dart';

/// The three figures that describe a multi-stop quote, on one line.
///
/// Three rather than two because a multi-stop quote is decided by three things — how many
/// stops, how far, and how many riders — and the third is what separates multi-drop from
/// batch at a glance: one rider, or one each.
class QuoteStats extends StatelessWidget {
  const QuoteStats({super.key, required this.cells});

  final List<({String label, String value})> cells;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: VinkolSpace.lg),
      decoration: BoxDecoration(
        color: v.surfaceAlt,
        borderRadius: VinkolRadius.brMd,
        border: VinkolElevation.hairline(v),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < cells.length; i++) ...<Widget>[
            if (i > 0)
              SizedBox(
                height: 34,
                child: VerticalDivider(width: 1, color: v.borderSubtle),
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    cells[i].value,
                    style: VinkolType.numL.copyWith(color: v.textPrimary),
                  ),
                  const SizedBox(height: VinkolSpace.xxs),
                  Text(
                    cells[i].label.toUpperCase(),
                    style: VinkolType.labelS.copyWith(color: v.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A card built from label/amount rows, ending in the total.
///
/// The amounts share one right-hand axis in tabular figures (signature #4), so a column of
/// prices reads as a column rather than as ragged text. The tax row appears only in a market
/// that shows tax separately — Nigeria returns null and grows no row.
class QuoteMoneyCard extends StatelessWidget {
  const QuoteMoneyCard({
    super.key,
    required this.lines,
    required this.subtotal,
    this.hint,
  });

  /// Label and already-formatted amount, in order.
  final List<({String label, String amount})> lines;

  /// The figure tax is computed on, and the base of the total.
  final double subtotal;

  /// One sentence on how this price was arrived at.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final TaxLine? tax = MarketFormat.tax(subtotal);
    final double total = subtotal + (tax?.amount.toDouble() ?? 0);

    return Container(
      padding: const EdgeInsets.all(VinkolSpace.cardPadding),
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brMd,
        border: VinkolElevation.hairline(v),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final ({String label, String amount}) line in lines)
            _MoneyRow(label: line.label, amount: line.amount),
          if (tax != null)
            _MoneyRow(
              label: '${tax.label} · ${tax.regionName}',
              amount: MarketFormat.money(tax.amount),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: VinkolSpace.md),
            child: Divider(height: 1, color: v.borderSubtle),
          ),
          _MoneyRow(
            label: context.l10n.bookingTotal,
            amount: MarketFormat.money(total),
            emphasised: true,
          ),
          if (hint != null) ...<Widget>[
            const SizedBox(height: VinkolSpace.md),
            Text(
              hint!,
              style: VinkolType.bodyS.copyWith(color: v.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.amount,
    this.emphasised = false,
  });

  final String label;
  final String amount;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VinkolSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: emphasised
                  ? VinkolType.h4.copyWith(color: v.textPrimary)
                  : VinkolType.body.copyWith(color: v.textSecondary),
            ),
          ),
          const SizedBox(width: VinkolSpace.md),
          Text(
            amount,
            style: emphasised
                ? VinkolType.numL.copyWith(color: v.textPrimary)
                : VinkolType.num.copyWith(color: v.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// One leg of a chained route: its position, where it goes, and how far that is.
class QuoteLegRow extends StatelessWidget {
  const QuoteLegRow({
    super.key,
    required this.marker,
    required this.title,
    required this.meta,
    this.value,
    this.showDivider = true,
    this.markerIsOrigin = false,
  });

  /// The stop number, or null-ish content for the origin, which takes an icon instead.
  final String marker;
  final String title;
  final String meta;

  /// The distance for this leg, already formatted.
  final String? value;

  final bool showDivider;
  final bool markerIsOrigin;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: VinkolSpace.md),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(top: BorderSide(color: v.borderSubtle)))
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StopMarker(label: marker, isOrigin: markerIsOrigin),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title,
                    style: VinkolType.h4.copyWith(color: v.textPrimary)),
                const SizedBox(height: VinkolSpace.xxs),
                Text(meta,
                    style: VinkolType.bodyS.copyWith(color: v.textSecondary)),
              ],
            ),
          ),
          if (value != null) ...<Widget>[
            const SizedBox(width: VinkolSpace.md),
            Text(value!,
                style: VinkolType.num.copyWith(color: v.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// A bordered card that groups rows without adding a second radius level.
class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VinkolSpace.cardPadding),
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brMd,
        border: VinkolElevation.hairline(v),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
