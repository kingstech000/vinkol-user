import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/extensions/currency_formatter.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/core/market/market_scope.dart';

/// The one big number on a transfer screen: how much.
///
/// The currency symbol is a fixed affix beside the field rather than a `prefixText`, and it
/// is placed by [MarketFormat.symbolIsPrefix] rather than assumed to the left — a market
/// whose currency suffixes would otherwise render `$1 234` where it means `1 234 $`. It sits
/// at reduced weight so the number stays the hero (signature #4).
class WalletAmountField extends StatefulWidget {
  const WalletAmountField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.error,
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;

  /// The standing fact under the field: the balance this will produce, or the balance it
  /// draws from. Replaced by [error] when there is one.
  final String? hint;
  final String? error;

  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  State<WalletAmountField> createState() => _WalletAmountFieldState();
}

class _WalletAmountFieldState extends State<WalletAmountField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final bool invalid = widget.error != null;
    final Color edge =
        invalid ? v.danger : (_focus.hasFocus ? v.brand : v.borderSubtle);

    final Widget symbol = Text(
      MarketFormat.symbol,
      style: VinkolType.numXl.copyWith(
        color: v.textTertiary,
        fontWeight: FontWeight.w500,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: VinkolType.label.copyWith(color: v.textSecondary),
        ),
        const SizedBox(height: VinkolSpace.labelToField),
        AnimatedContainer(
          duration: VinkolMotion.respecting(context, VinkolMotion.fast),
          curve: VinkolMotion.standard,
          constraints: const BoxConstraints(minHeight: 74),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: VinkolSpace.lg,
            vertical: VinkolSpace.md,
          ),
          decoration: BoxDecoration(
            color: widget.enabled ? v.surface : v.surfaceAlt,
            borderRadius: VinkolRadius.brSm,
            border: Border.fromBorderSide(
              BorderSide(
                color: edge,
                width: _focus.hasFocus || invalid ? 2 : 1,
              ),
            ),
            // The form archetype's focus halo, unchanged: the opacity here is a state
            // change, not a derived colour.
            boxShadow: _focus.hasFocus
                ? <BoxShadow>[BoxShadow(color: v.brandHalo, spreadRadius: 3)]
                : VinkolElevation.e0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (MarketFormat.symbolIsPrefix) ...<Widget>[
                symbol,
                const SizedBox(width: VinkolSpace.sm),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  onChanged: widget.onChanged,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: MarketScope.market.currency.decimalDigits > 0,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    CurrencyFormatter.amountFormatter,
                  ],
                  style: VinkolType.numXl.copyWith(color: v.textPrimary),
                  cursorColor: v.brand,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: MarketFormat.amount(0),
                    hintStyle: VinkolType.numXl.copyWith(color: v.textTertiary),
                  ),
                ),
              ),
              if (!MarketFormat.symbolIsPrefix) ...<Widget>[
                const SizedBox(width: VinkolSpace.sm),
                symbol,
              ],
            ],
          ),
        ),
        if (widget.error != null || widget.hint != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            widget.error ?? widget.hint!,
            style: VinkolType.bodyS
                .copyWith(color: invalid ? v.danger : v.textTertiary),
          ),
        ],
      ],
    );
  }
}
