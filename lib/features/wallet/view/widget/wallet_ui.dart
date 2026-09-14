import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_motion.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/wallet/model/bank_model.dart';
import 'package:starter_codes/features/wallet/model/payment_history_model.dart';
import 'package:starter_codes/features/wallet/model/withdrawal_model.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/price_text.dart';
import 'package:starter_codes/widgets/state_view.dart';

/// The pieces every wallet screen shares. A payment and a withdrawal are both
/// lines on the same ledger, so they render through one row and one detail
/// page rather than two of each.

// ---------------------------------------------------------------------------
// The ledger entry
// ---------------------------------------------------------------------------

/// How an entry ended up. `pending` is the one that matters most: it is the
/// only state in which the money is somewhere between two places.
enum WalletEntryState { succeeded, pending, failed }

/// One line on the ledger, whichever endpoint it came from.
class WalletEntry {
  const WalletEntry({
    required this.id,
    required this.title,
    required this.money,
    required this.isCredit,
    required this.statusLabel,
    required this.state,
    required this.createdAt,
    required this.kind,
    this.reference,
    this.note,
    this.bankName,
    this.accountNumber,
  });

  /// A card or transfer into the wallet, or a payment out of it.
  factory WalletEntry.fromPayment(PaymentHistory p) {
    final isCredit = p.type.toLowerCase() != 'debit';
    return WalletEntry(
      id: p.id,
      title: p.narration.isNotEmpty
          ? p.narration
          : (isCredit ? 'Top-up' : 'Payment'),
      money: p.money,
      isCredit: isCredit,
      statusLabel: _sentence(p.status),
      state: stateOf(p.status),
      createdAt: p.createdAt,
      kind: isCredit ? 'Top-up' : 'Payment',
      reference: p.reference.isEmpty ? null : p.reference,
      // The narration is already the title; repeating it as a note says
      // nothing new.
    );
  }

  /// Money sent from the wallet to the customer's bank. The bank is the
  /// title: "Withdrawal to" in front of it only ate the bank's name on a
  /// tab that is already called Withdrawals.
  factory WalletEntry.fromWithdrawal(Withdrawal w) {
    return WalletEntry(
      id: w.id ?? '',
      title: w.bankName == null || w.bankName!.isEmpty
          ? 'Withdrawal'
          : w.bankName!,
      money: w.money,
      isCredit: false,
      statusLabel: _sentence(w.status),
      state: stateOf(w.status),
      createdAt: w.createdAt,
      kind: 'Withdrawal',
      reference: w.id,
      note: w.reason,
      bankName: w.bankName,
      accountNumber: w.accountNumber,
    );
  }

  final String id;
  final String title;
  final Money money;
  final bool isCredit;

  /// The backend's word for where this is, in sentence case. Shown as-is so
  /// the app never claims a state the server did not.
  final String statusLabel;
  final WalletEntryState state;
  final DateTime? createdAt;

  /// Top-up · Payment · Withdrawal.
  final String kind;
  final String? reference;
  final String? note;
  final String? bankName;
  final String? accountNumber;

  /// The sign that precedes the amount everywhere it is drawn.
  String get sign => isCredit ? '+' : '−';

  /// "13 Sep 2026"
  String get dateLabel =>
      createdAt == null ? '—' : DateFormat('d MMM yyyy').format(createdAt!.toLocal());

  /// "14:02"
  String get timeLabel =>
      createdAt == null ? '—' : DateFormat('HH:mm').format(createdAt!.toLocal());

  /// The backend spells the same outcome several ways; fold them.
  static WalletEntryState stateOf(String status) {
    switch (status.toLowerCase()) {
      case 'successful':
      case 'success':
      case 'approved':
      case 'completed':
      case 'paid':
        return WalletEntryState.succeeded;
      case 'pending':
      case 'processing':
        return WalletEntryState.pending;
      default:
        return WalletEntryState.failed;
    }
  }

  static String _sentence(String s) {
    final t = s.trim();
    if (t.isEmpty) return 'Unknown';
    return t[0].toUpperCase() + t.substring(1).toLowerCase();
  }
}

// ---------------------------------------------------------------------------
// Status
// ---------------------------------------------------------------------------

/// The status triple (decision D-05): the word first, then a shape that
/// differs in grayscale — filled dot, hollow ring, diamond — then the colour.
class WalletStatusPill extends StatelessWidget {
  const WalletStatusPill({
    super.key,
    required this.label,
    required this.state,
  });

  final String label;
  final WalletEntryState state;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final Color ground;
    switch (state) {
      case WalletEntryState.succeeded:
        color = VinkolPalette.successText;
        ground = VinkolPalette.successGround;
      case WalletEntryState.pending:
        color = VinkolPalette.warningText;
        ground = VinkolPalette.warningGround;
      case WalletEntryState.failed:
        color = VinkolPalette.dangerText;
        ground = VinkolPalette.dangerGround;
    }

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: VinkolSpace.sm,
          vertical: VinkolSpace.xs,
        ),
        decoration: BoxDecoration(
          color: ground,
          borderRadius: VinkolRadius.brFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusShape(state: state, color: color),
            Gap.w6,
            AppText.caption(
              label,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusShape extends StatelessWidget {
  const _StatusShape({required this.state, required this.color});

  final WalletEntryState state;
  final Color color;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case WalletEntryState.succeeded:
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        );
      case WalletEntryState.pending:
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
        );
      case WalletEntryState.failed:
        return Transform.rotate(
          angle: 0.785398, // 45°
          child: Container(width: 7, height: 7, color: color),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// The ledger row
// ---------------------------------------------------------------------------

/// One entry: a bare direction glyph, what it was and when, and the amount
/// flush on the right with its sign. Success is the default and says nothing;
/// only an entry that is still moving, or that failed, wears a status.
class WalletEntryRow extends StatelessWidget {
  const WalletEntryRow({super.key, required this.entry, this.onTap});

  final WalletEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showStatus = entry.state != WalletEntryState.succeeded;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: VinkolSpace.lg,
            vertical: VinkolSpace.md + 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                entry.isCredit
                    ? PhosphorIconsRegular.arrowDownLeft
                    : PhosphorIconsRegular.arrowUpRight,
                size: 20,
                color: VinkolPalette.neutral500,
                semanticLabel: entry.isCredit ? 'Money in' : 'Money out',
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.body(
                      entry.title,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: VinkolPalette.neutral900,
                      maxLines: 1,
                    ),
                    Gap.h2,
                    AppText.caption(
                      '${entry.dateLabel} · ${entry.timeLabel}',
                      fontSize: 13,
                      color: VinkolPalette.neutral500,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Gap.w12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PriceText(
                    entry.money,
                    prefix: entry.sign,
                    size: 15,
                    color: entry.isCredit
                        ? VinkolPalette.successText
                        : VinkolPalette.neutral900,
                    symbolColor: entry.isCredit
                        ? VinkolPalette.successText
                        : VinkolPalette.neutral500,
                  ),
                  if (showStatus) ...[
                    Gap.h4,
                    WalletStatusPill(
                      label: entry.statusLabel,
                      state: entry.state,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The row while the ledger is loading. Same geometry, no content.
class WalletEntryRowSkeleton extends StatelessWidget {
  const WalletEntryRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: VinkolSpace.lg,
        vertical: VinkolSpace.lg,
      ),
      child: Row(
        children: [
          SkeletonBox(width: 20, height: 20, borderRadius: VinkolRadius.brFull),
          Gap.w(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 140, height: 14),
                Gap.h(6),
                SkeletonBox(width: 96, height: 12),
              ],
            ),
          ),
          SkeletonBox(width: 72, height: 14),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Surfaces and rows
// ---------------------------------------------------------------------------

/// The one white surface a group of rows sits on: hairline border, hairlines
/// between the rows, nothing lifted (e0).
class WalletSurface extends StatelessWidget {
  const WalletSurface({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VinkolPalette.white,
        borderRadius: VinkolRadius.brMd,
        border: Border.all(color: VinkolPalette.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(
                height: 1,
                indent: VinkolSpace.lg,
                endIndent: VinkolSpace.lg,
                color: VinkolPalette.neutral100,
              ),
          ],
        ],
      ),
    );
  }
}

/// Label on the left, value flush right. Money values go through [PriceText]
/// so every amount on a screen shares one axis (signature #4).
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({super.key, required this.label, required this.value})
      : money = null,
        moneyPrefix = null;

  const KeyValueRow.money(
      {super.key, required this.label, required Money this.money, this.moneyPrefix})
      : value = null;

  final String label;
  final String? value;
  final Money? money;
  final String? moneyPrefix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VinkolSpace.lg,
        vertical: VinkolSpace.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.body(
            label,
            fontSize: 14,
            color: VinkolPalette.neutral500,
          ),
          Gap.w16,
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: money != null
                  ? PriceText(money!, prefix: moneyPrefix, size: 14)
                  : AppText.body(
                      value ?? '—',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: VinkolPalette.neutral900,
                      textAlign: TextAlign.end,
                      maxLines: 3,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A bank account as one line: bank, holder, and the last four digits. The
/// same row on the withdraw screen and in the confirmation sheet.
class BankAccountRow extends StatelessWidget {
  const BankAccountRow({super.key, required this.bank, this.trailing});

  final UserBank bank;
  final Widget? trailing;

  static String lastFour(String accountNumber) => accountNumber.length <= 4
      ? accountNumber
      : accountNumber.substring(accountNumber.length - 4);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VinkolSpace.lg,
        vertical: VinkolSpace.md + 2,
      ),
      child: Row(
        children: [
          const Icon(
            PhosphorIconsRegular.bank,
            size: 20,
            color: VinkolPalette.neutral500,
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.body(
                  bank.bankName,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.neutral900,
                  maxLines: 1,
                ),
                Gap.h2,
                AppText.caption(
                  '···· ${lastFour(bank.accountNumber)} · ${bank.accountName}',
                  fontSize: 13,
                  color: VinkolPalette.neutral500,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[Gap.w8, trailing!],
        ],
      ),
    );
  }
}

/// A single-line notice that sits with the content rather than shouting over
/// it: a bare glyph, a sentence, and optionally one text action.
class InlineNotice extends StatelessWidget {
  const InlineNotice({
    super.key,
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
    this.tone = InlineNoticeTone.neutral,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;
  final InlineNoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final Color border;
    switch (tone) {
      case InlineNoticeTone.neutral:
        color = VinkolPalette.neutral700;
        border = VinkolPalette.neutral200;
      case InlineNoticeTone.success:
        color = VinkolPalette.successText;
        border = VinkolPalette.successGround;
      case InlineNoticeTone.danger:
        color = VinkolPalette.dangerText;
        border = VinkolPalette.dangerGround;
    }
    return Container(
      padding: const EdgeInsets.all(VinkolSpace.lg),
      decoration: BoxDecoration(
        color: VinkolPalette.white,
        borderRadius: VinkolRadius.brMd,
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          Gap.w12,
          Expanded(
            child: AppText.body(
              text,
              fontSize: 14,
              color: color,
              maxLines: 3,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            Gap.w8,
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: VinkolSpace.sm),
              ),
              child: AppText.button(
                actionLabel!,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: VinkolPalette.brand600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum InlineNoticeTone { neutral, success, danger }

// ---------------------------------------------------------------------------
// Forms
// ---------------------------------------------------------------------------

/// A field's label, with the room below it the token asks for.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: VinkolSpace.labelToField),
      child: AppText.caption(
        text,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: VinkolPalette.neutral700,
      ),
    );
  }
}

/// The wallet's input decoration: hairline at rest, brand at focus, the error
/// stated in words under the field. Same shape as the search field.
InputDecoration walletFieldDecoration({
  required String hint,
  String? prefixText,
  Widget? suffixIcon,
  String? helperText,
}) {
  const border = OutlineInputBorder(
    borderRadius: VinkolRadius.brSm,
    borderSide: BorderSide(color: VinkolPalette.neutral200),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 15, color: VinkolPalette.neutral400),
    // A widget, not `prefixText`: Flutter hides prefix text until the field
    // is focused, and the currency should be there before the first digit.
    prefixIcon: prefixText == null
        ? null
        : Padding(
            padding: const EdgeInsetsDirectional.only(
              start: VinkolSpace.md,
              end: VinkolSpace.xs,
            ),
            child: Text(
              prefixText,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: VinkolPalette.neutral500,
              ),
            ),
          ),
    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    suffixIcon: suffixIcon,
    helperText: helperText,
    helperStyle: const TextStyle(fontSize: 12, color: VinkolPalette.neutral600),
    errorStyle: const TextStyle(fontSize: 12, color: VinkolPalette.dangerText),
    errorMaxLines: 2,
    counterText: '',
    isDense: true,
    filled: true,
    // Disabled sinks into the canvas so it reads as not-yet, not as broken.
    fillColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? VinkolPalette.neutral50
          : VinkolPalette.white,
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: VinkolSpace.md,
      vertical: VinkolSpace.md + 2,
    ),
    border: border,
    enabledBorder: border,
    disabledBorder: const OutlineInputBorder(
      borderRadius: VinkolRadius.brSm,
      borderSide: BorderSide(color: VinkolPalette.neutral100),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: VinkolRadius.brSm,
      borderSide: BorderSide(color: VinkolPalette.brand500, width: 1.5),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: VinkolRadius.brSm,
      borderSide: BorderSide(color: VinkolPalette.dangerText),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: VinkolRadius.brSm,
      borderSide: BorderSide(color: VinkolPalette.dangerText, width: 1.5),
    ),
  );
}

/// The text style for what the customer types.
const walletFieldTextStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w500,
  color: VinkolPalette.neutral900,
);

/// The typed amount, tabular so digits do not jitter as they are entered.
const walletAmountTextStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w600,
  color: VinkolPalette.neutral900,
  fontFeatures: [FontFeature.tabularFigures()],
);

/// A 20pt indicator sized to sit inside a field's suffix slot.
class FieldSpinner extends StatelessWidget {
  const FieldSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(VinkolSpace.md),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: VinkolPalette.brand500,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheets and bars
// ---------------------------------------------------------------------------

/// The bottom sheet chrome: rounded at the top only, a handle, then whatever
/// the sheet is for. Keyboard insets are handled here so callers do not.
class WalletSheet extends StatelessWidget {
  const WalletSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: VinkolPalette.white,
        borderRadius: VinkolRadius.brSheet,
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            VinkolSpace.pageMargin,
            VinkolSpace.sm,
            VinkolSpace.pageMargin,
            VinkolSpace.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: VinkolPalette.neutral200,
                    borderRadius: VinkolRadius.brFull,
                  ),
                ),
              ),
              Gap.h20,
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// The pinned primary action. Blocked, it keeps its shape and says what is
/// missing above it — nothing on these screens is disabled in silence.
class WalletActionBar extends StatelessWidget {
  const WalletActionBar({
    super.key,
    required this.child,
    this.blocker,
  });

  final Widget child;
  final String? blocker;

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedSize(
                duration: VinkolMotion.respecting(context, VinkolMotion.fast),
                curve: VinkolMotion.standard,
                alignment: Alignment.topCenter,
                child: blocker == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsetsDirectional.only(
                            bottom: VinkolSpace.sm + 2),
                        child: Row(
                          children: [
                            const Icon(
                              PhosphorIconsRegular.info,
                              size: 16,
                              color: VinkolPalette.neutral500,
                            ),
                            Gap.w6,
                            Expanded(
                              child: AppText.caption(
                                blocker!,
                                fontSize: 13,
                                color: VinkolPalette.neutral600,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// A section's heading, used once per group on a screen. neutral.600, not
/// 500: at 12px on the canvas 500 is only 4.04:1.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: VinkolSpace.sm),
      child: AppText.caption(
        text,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: VinkolPalette.neutral600,
        letterSpacing: 0.3,
      ),
    );
  }
}
