import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/features/wallet/model/payment_history_model.dart';
import 'package:starter_codes/features/wallet/model/withdrawal_model.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_status_badge.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Date and time for a wallet row, in the reader's locale.
///
/// Through [MaterialLocalizations] rather than a `DateFormat` pattern: a hardcoded
/// `d MMM` renders `3 Sep` to a francophone reader who expects `3 sept.`, and the 12/24-hour
/// choice is the device's, not ours.
String walletTimestamp(BuildContext context, DateTime when) {
  final ml = MaterialLocalizations.of(context);
  final local = when.toLocal();
  return '${ml.formatMediumDate(local)} · '
      '${ml.formatTimeOfDay(
    TimeOfDay.fromDateTime(local),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  )}';
}

/// One payment in the Payments tab.
///
/// A row rather than a widget, because [VinkolRowGroup] takes `VinkolRow`s: the group is what
/// draws the single bordered container and the hairlines between rows, and a wrapper widget
/// would put every row in its own card instead.
///
/// Money out is the default ink; money in is the one green thing in the list, because a
/// top-up is the exception in a list of spending. The status badge appears **only when the
/// payment did not settle** — a column of "Successful" badges beside a column of amounts is
/// noise that hides the one row that needs reading.
VinkolRow walletPaymentRow(
  BuildContext context,
  PaymentHistory payment, {
  VoidCallback? onTap,
}) {
  final l10n = context.l10n;
  final bool credit = payment.type != 'Debit';

  return VinkolRow(
    title: payment.narration.isNotEmpty
        ? payment.narration
        : (credit ? l10n.walletTopUp : l10n.walletPayment),
    meta: walletTimestamp(context, payment.createdAt),
    icon: credit ? Icons.south_west : Icons.north_east,
    accentIcon: credit,
    onTap: onTap,
    trailing: _Amount(
      amount: payment.amount,
      credit: credit,
      status: isSettled(payment.status) ? null : payment.status,
      kind: WalletStatusKind.payment,
    ),
  );
}

/// One withdrawal in the Withdrawals tab.
///
/// Unlike a payment, a withdrawal carries its status on every row: a request sits in
/// `Pending` for as long as the bank takes, and "has my money left yet" is the only question
/// this list exists to answer.
VinkolRow walletWithdrawalRow(BuildContext context, Withdrawal withdrawal) {
  final l10n = context.l10n;
  final DateTime? when = withdrawal.createdAt;

  return VinkolRow(
    title: withdrawal.bankName ?? l10n.walletBankTransfer,
    meta: when != null ? walletTimestamp(context, when) : l10n.walletWithdrawal,
    icon: Icons.account_balance_outlined,
    trailing: _Amount(
      amount: withdrawal.amount,
      credit: false,
      status: withdrawal.status,
      kind: WalletStatusKind.withdrawal,
    ),
  );
}

/// The end-axis column: the signed amount, and the status underneath when there is one to
/// report. Both are end-aligned so every row in the list shares one optical axis
/// (signature #4) whatever the currency's symbol does to the width.
class _Amount extends StatelessWidget {
  const _Amount({
    required this.amount,
    required this.credit,
    required this.status,
    required this.kind,
  });

  final double amount;
  final bool credit;
  final String? status;
  final WalletStatusKind kind;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          // U+2212, not a hyphen: a hyphen is narrower than the digits beside it and breaks
          // the tabular column.
          '${credit ? '+' : '−'}${MarketFormat.money(amount.abs())}',
          style: VinkolType.num.copyWith(
            color: credit ? v.success : v.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.end,
        ),
        if (status != null) ...<Widget>[
          const SizedBox(height: VinkolSpace.xs),
          WalletStatusBadge(status: status!, kind: kind, dense: true),
        ],
      ],
    );
  }
}
