import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/store/view/widget/store_ui.dart';
import 'package:starter_codes/widgets/gap.dart';

/// The checkout's building blocks, in the order they appear on the cart
/// screen: where it goes, how it gets there, how it is paid for, what it
/// comes to.

/// A section heading on the cart.
class CheckoutSectionLabel extends StatelessWidget {
  const CheckoutSectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppText.h4(
            text,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: VinkolPalette.neutral900,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Where the order is going. Empty, it is the next thing to do and says so;
/// set, it shows the address and offers to change it.
class DeliveryAddressRow extends StatelessWidget {
  const DeliveryAddressRow({
    super.key,
    required this.address,
    required this.onTap,
  });

  final String? address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSet = address != null && address!.trim().isNotEmpty;

    return Semantics(
      button: true,
      label: isSet ? 'Delivering to $address. Change' : 'Add delivery address',
      child: Material(
        color: VinkolPalette.white,
        shape: RoundedRectangleBorder(
          borderRadius: VinkolRadius.brMd,
          side: BorderSide(
            color: isSet ? VinkolPalette.neutral200 : VinkolPalette.brand500,
            width: isSet ? 1 : 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(VinkolSpace.lg),
            child: Row(
              children: [
                Icon(
                  isSet
                      ? PhosphorIconsFill.mapPin
                      : PhosphorIconsRegular.mapPinPlus,
                  size: 22,
                  color: VinkolPalette.brand600,
                ),
                Gap.w12,
                Expanded(
                  child: isSet
                      ? AppText.body(
                          address!.trim(),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: VinkolPalette.neutral900,
                          maxLines: 2,
                          lineHeight: 1.3,
                        )
                      : AppText.body(
                          'Add a delivery address',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: VinkolPalette.brand600,
                        ),
                ),
                Gap.w8,
                AppText.caption(
                  isSet ? 'Change' : 'Add',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.brand600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One way of getting the order there. A radio row: name, what it is, price
/// flush on the end. Unavailable options stay in the list with the reason —
/// hiding them would make the customer wonder where the cheap one went.
class DeliveryOptionTile extends StatelessWidget {
  const DeliveryOptionTile({
    super.key,
    required this.quote,
    required this.selected,
    required this.onTap,
  });

  final QuoteResponseModel quote;
  final bool selected;
  final VoidCallback onTap;

  String get _title => switch (quote.deliveryType.toLowerCase()) {
        'priority' => 'Priority',
        'express' => 'Standard',
        _ => quote.deliveryType,
      };

  String get _subtitle => switch (quote.deliveryType.toLowerCase()) {
        'priority' => 'Fastest option, partner courier',
        'express' => 'A Vinkol rider',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final available = quote.isAvailable;
    final reason = quote.unavailableMessage?.trim();

    return Semantics(
      button: available,
      selected: selected,
      label: '$_title, ${available ? quote.amountDue.format() : 'unavailable'}',
      child: Material(
        color: selected ? VinkolPalette.brand50 : VinkolPalette.white,
        shape: RoundedRectangleBorder(
          borderRadius: VinkolRadius.brMd,
          side: BorderSide(
            color: selected ? VinkolPalette.brand500 : VinkolPalette.neutral200,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: available ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(VinkolSpace.lg),
            child: Row(
              children: [
                _Radio(selected: selected, enabled: available),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.body(
                        _title,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: available
                            ? VinkolPalette.neutral900
                            : VinkolPalette.neutral500,
                      ),
                      if (available && _subtitle.isNotEmpty) ...[
                        Gap.h2,
                        AppText.caption(
                          _subtitle,
                          fontSize: 13,
                          color: VinkolPalette.neutral500,
                        ),
                      ],
                      if (!available) ...[
                        Gap.h2,
                        AppText.caption(
                          reason != null && reason.isNotEmpty
                              ? reason
                              : 'Not available for this address',
                          fontSize: 13,
                          color: VinkolPalette.neutral500,
                          maxLines: 2,
                        ),
                      ],
                    ],
                  ),
                ),
                Gap.w12,
                if (available)
                  PriceText(quote.amountDue, size: 15)
                else
                  AppText.caption(
                    'Unavailable',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: VinkolPalette.neutral500,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A radio drawn as shape, not just colour: hollow ring at rest, ring with a
/// filled centre when chosen.
class _Radio extends StatelessWidget {
  const _Radio({required this.selected, required this.enabled});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? VinkolPalette.neutral300
        : selected
            ? VinkolPalette.brand500
            : VinkolPalette.neutral400;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: selected ? 2 : 1.5),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            )
          : null,
    );
  }
}

/// A skeleton for the two option rows while the server prices the delivery.
class DeliveryOptionsSkeleton extends StatelessWidget {
  const DeliveryOptionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget row() => Container(
          padding: const EdgeInsets.all(VinkolSpace.lg),
          decoration: BoxDecoration(
            borderRadius: VinkolRadius.brMd,
            border: Border.all(color: VinkolPalette.neutral200),
          ),
          child: const Row(
            children: [
              SkeletonBox(
                  width: 20, height: 20, borderRadius: VinkolRadius.brFull),
              Gap.w(VinkolSpace.md),
              Expanded(child: SkeletonBox(width: 120, height: 16)),
              SkeletonBox(width: 64, height: 16),
            ],
          ),
        );
    return Column(children: [row(), Gap.h10, row()]);
  }
}

/// How the order is paid for. In a market with one source there is nothing
/// to choose, so the row states it and does not open anything.
class PaymentMethodRow extends StatelessWidget {
  const PaymentMethodRow({
    super.key,
    required this.method,
    required this.detail,
    required this.onTap,
  });

  final String method;

  /// The wallet balance, or a word on the card.
  final String? detail;

  /// Null when the market offers no choice.
  final VoidCallback? onTap;

  static IconData iconFor(String source) => switch (source) {
        'Wallet' => PhosphorIconsRegular.wallet,
        _ => PhosphorIconsRegular.creditCard,
      };

  static String labelFor(String source) => switch (source) {
        'Wallet' => 'Vinkol wallet',
        'Paystack' => 'Card or bank, via Paystack',
        'Stripe' => 'Card, via Stripe',
        _ => source,
      };

  @override
  Widget build(BuildContext context) {
    final canChange = onTap != null;
    return Semantics(
      button: canChange,
      label: 'Paying with ${labelFor(method)}${canChange ? '. Change' : ''}',
      child: Material(
        color: VinkolPalette.white,
        shape: const RoundedRectangleBorder(
          borderRadius: VinkolRadius.brMd,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(VinkolSpace.lg),
            child: Row(
              children: [
                Icon(iconFor(method),
                    size: 22, color: VinkolPalette.neutral700),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.body(
                        labelFor(method),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: VinkolPalette.neutral900,
                      ),
                      if (detail != null && detail!.isNotEmpty) ...[
                        Gap.h2,
                        AppText.caption(
                          detail!,
                          fontSize: 13,
                          color: VinkolPalette.neutral500,
                        ),
                      ],
                    ],
                  ),
                ),
                if (canChange) ...[
                  Gap.w8,
                  AppText.caption(
                    'Change',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: VinkolPalette.brand600,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The sheet behind [PaymentMethodRow]'s "Change".
Future<String?> showPaymentSourceSheet(
  BuildContext context, {
  required List<String> sources,
  required String selected,
  required Money? walletBalance,
  required bool walletInsufficient,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: VinkolPalette.white,
    shape: const RoundedRectangleBorder(borderRadius: VinkolRadius.brSheet),
    builder: (context) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            VinkolSpace.pageMargin,
            VinkolSpace.lg,
            VinkolSpace.pageMargin,
            VinkolSpace.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.h3(
                'Pay with',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: VinkolPalette.neutral900,
              ),
              Gap.h16,
              for (final source in sources) ...[
                _PaymentSourceTile(
                  source: source,
                  selected: source == selected,
                  disabled: source == 'Wallet' && walletInsufficient,
                  detail: source == 'Wallet'
                      ? walletInsufficient
                          ? 'Not enough in your wallet for this order'
                          : walletBalance != null
                              ? 'Balance ${walletBalance.format()}'
                              : null
                      : null,
                  onTap: () => Navigator.of(context).pop(source),
                ),
                if (source != sources.last) Gap.h10,
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _PaymentSourceTile extends StatelessWidget {
  const _PaymentSourceTile({
    required this.source,
    required this.selected,
    required this.disabled,
    required this.detail,
    required this.onTap,
  });

  final String source;
  final bool selected;
  final bool disabled;
  final String? detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? VinkolPalette.brand50 : VinkolPalette.white,
      shape: RoundedRectangleBorder(
        borderRadius: VinkolRadius.brMd,
        side: BorderSide(
          color: selected ? VinkolPalette.brand500 : VinkolPalette.neutral200,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(VinkolSpace.lg),
          child: Row(
            children: [
              _Radio(selected: selected, enabled: !disabled),
              Gap.w12,
              Icon(
                PaymentMethodRow.iconFor(source),
                size: 22,
                color: disabled
                    ? VinkolPalette.neutral400
                    : VinkolPalette.neutral700,
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.body(
                      PaymentMethodRow.labelFor(source),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: disabled
                          ? VinkolPalette.neutral500
                          : VinkolPalette.neutral900,
                    ),
                    if (detail != null) ...[
                      Gap.h2,
                      AppText.caption(
                        detail!,
                        fontSize: 13,
                        color: disabled
                            ? VinkolPalette.warningText
                            : VinkolPalette.neutral500,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Every line before the total, then the total (skill: checkout). Labels on
/// the start, amounts flush on the end in tabular figures, so the column of
/// numbers reads as a column.
class OrderSummary extends StatelessWidget {
  const OrderSummary({
    super.key,
    required this.subtotal,
    required this.delivery,
    this.deliveryPlaceholder = 'Choose an option',
    required this.serviceFee,
    required this.tax,
    required this.taxLabel,
    required this.total,
  });

  final Money subtotal;

  /// Null until a delivery option is chosen.
  final Money? delivery;

  /// What to say in the delivery line while there is no price yet.
  final String deliveryPlaceholder;
  final Money? serviceFee;
  final Money? tax;
  final String? taxLabel;
  final Money total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryLine(label: 'Items', amount: subtotal),
        Gap.h10,
        _SummaryLine(
          label: 'Delivery',
          amount: delivery,
          placeholder: deliveryPlaceholder,
        ),
        if (serviceFee != null && !serviceFee!.isZero) ...[
          Gap.h10,
          _SummaryLine(label: 'Processing fee', amount: serviceFee),
        ],
        if (tax != null && !tax!.isZero) ...[
          Gap.h10,
          _SummaryLine(
            label: taxLabel?.isNotEmpty == true ? taxLabel! : 'Tax',
            amount: tax,
          ),
        ],
        Gap.h12,
        const Divider(height: 1, color: VinkolPalette.neutral200),
        Gap.h12,
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: AppText.body(
                'Total',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VinkolPalette.neutral900,
              ),
            ),
            PriceText.large(total),
          ],
        ),
      ],
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.amount,
    this.placeholder,
  });

  final String label;
  final Money? amount;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppText.body(
            label,
            fontSize: 14,
            color: VinkolPalette.neutral600,
          ),
        ),
        if (amount != null)
          PriceText(amount!, size: 14, weight: FontWeight.w500)
        else
          AppText.caption(
            placeholder ?? '—',
            fontSize: 13,
            color: VinkolPalette.neutral400,
          ),
      ],
    );
  }
}
