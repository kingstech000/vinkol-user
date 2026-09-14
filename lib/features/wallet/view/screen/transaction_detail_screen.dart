import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_motion.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_ui.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/price_text.dart';

/// One ledger entry in full: the amount, where it stands, and every fact the
/// record carries. Payments and withdrawals share it.
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.entry});

  final WalletEntry entry;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    return Scaffold(
      appBar: MiniAppBar(title: e.kind),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            VinkolSpace.pageMargin,
            VinkolSpace.lg,
            VinkolSpace.pageMargin,
            VinkolSpace.xxxl,
          ),
          children: [
            // The hero: what it was, how much, and where it stands.
            AppText.body(
              e.title,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: VinkolPalette.neutral600,
              maxLines: 2,
            ),
            Gap.h6,
            PriceText(
              e.money,
              prefix: e.sign,
              size: 36,
              weight: FontWeight.w800,
              color: e.isCredit
                  ? VinkolPalette.successText
                  : VinkolPalette.neutral900,
              symbolColor: e.isCredit
                  ? VinkolPalette.successText
                  : VinkolPalette.neutral500,
            ),
            Gap.h10,
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: WalletStatusPill(label: e.statusLabel, state: e.state),
            ),
            if (e.state == WalletEntryState.pending) ...[
              Gap.h16,
              InlineNotice(
                icon: PhosphorIconsRegular.clock,
                text: e.kind == 'Withdrawal'
                    ? 'Being sent to your bank. Pull down on the wallet to check for an update.'
                    : 'Still being confirmed. The balance updates once it goes through.',
              ),
            ],
            Gap.h28,
            const SectionLabel('DETAILS'),
            WalletSurface(
              children: [
                KeyValueRow(label: 'Date', value: e.dateLabel),
                KeyValueRow(label: 'Time', value: e.timeLabel),
                KeyValueRow(label: 'Type', value: e.kind),
                if (e.bankName != null && e.bankName!.isNotEmpty)
                  KeyValueRow(label: 'Bank', value: e.bankName!),
                if (e.accountNumber != null && e.accountNumber!.isNotEmpty)
                  KeyValueRow(
                    label: 'Account',
                    value: '···· ${BankAccountRow.lastFour(e.accountNumber!)}',
                  ),
                if (e.note != null && e.note!.isNotEmpty)
                  KeyValueRow(label: 'Note', value: e.note!),
              ],
            ),
            if (e.reference != null && e.reference!.isNotEmpty) ...[
              Gap.h28,
              const SectionLabel('REFERENCE'),
              _ReferenceRow(reference: e.reference!),
              Gap.h8,
              AppText.caption(
                'Quote this if you contact support about this transaction.',
                fontSize: 12,
                color: VinkolPalette.neutral600,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The reference in mono, with a copy control that confirms in place — the
/// icon becomes a tick for a moment rather than raising a dialog.
class _ReferenceRow extends StatefulWidget {
  const _ReferenceRow({required this.reference});

  final String reference;

  @override
  State<_ReferenceRow> createState() => _ReferenceRowState();
}

class _ReferenceRowState extends State<_ReferenceRow> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.reference));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        VinkolSpace.lg,
        VinkolSpace.xs,
        VinkolSpace.xs,
        VinkolSpace.xs,
      ),
      decoration: BoxDecoration(
        color: VinkolPalette.white,
        borderRadius: VinkolRadius.brSm,
        border: Border.all(color: VinkolPalette.neutral200),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              widget.reference,
              style: const TextStyle(
                fontFamily: 'menlo',
                fontFamilyFallback: ['Courier', 'monospace'],
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: VinkolPalette.neutral900,
                height: 1.4,
              ),
            ),
          ),
          Gap.w8,
          IconButton(
            tooltip: _copied ? 'Copied' : 'Copy reference',
            onPressed: _copy,
            icon: AnimatedSwitcher(
              duration: VinkolMotion.respecting(context, VinkolMotion.fast),
              child: Icon(
                _copied
                    ? PhosphorIconsRegular.check
                    : PhosphorIconsRegular.copy,
                key: ValueKey(_copied),
                size: 20,
                color: _copied
                    ? VinkolPalette.successText
                    : VinkolPalette.brand600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
