import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/features/wallet/model/payment_history_model.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_rows.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_status_badge.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// One payment, in full.
///
/// The screen exists for two questions: did it go through, and what do I quote to support.
/// So the amount and the status lead, and the reference is one tap from the clipboard rather
/// than something to read off a screen into a chat window.
///
/// There is no receipt button. There is no receipt endpoint (D-10), and a button that
/// generates a document the server never issued would be inventing a record.
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transaction});

  final PaymentHistory transaction;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final bool credit = transaction.type != 'Debit';

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: AppBar(
        backgroundColor: v.canvas,
        surfaceTintColor: v.canvas,
        elevation: 0,
        title: Text(l10n.walletTransaction,
            style: VinkolType.h3.copyWith(color: v.textPrimary)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            VinkolSpace.pageMargin,
            VinkolSpace.sm,
            VinkolSpace.pageMargin,
            VinkolSpace.xxxl,
          ),
          children: <Widget>[
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: credit ? v.successGround : v.brandSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        credit ? Icons.south_west : Icons.north_east,
                        size: 24,
                        color: credit ? v.success : v.brand,
                      ),
                    ),
                  ),
                  const SizedBox(height: VinkolSpace.lg),
                  Text(
                    '${credit ? '+' : '−'}'
                    '${MarketFormat.moneyPrecise(transaction.amount.abs())}',
                    textAlign: TextAlign.center,
                    style: VinkolType.numXl.copyWith(
                      color: credit ? v.success : v.textPrimary,
                    ),
                  ),
                  if (transaction.narration.isNotEmpty) ...<Widget>[
                    const SizedBox(height: VinkolSpace.sm),
                    Text(
                      transaction.narration,
                      textAlign: TextAlign.center,
                      style: VinkolType.bodyS.copyWith(color: v.textTertiary),
                    ),
                  ],
                  const SizedBox(height: VinkolSpace.lg),
                  Align(
                    alignment: Alignment.center,
                    child: WalletStatusBadge(status: transaction.status),
                  ),
                ],
              ),
            ),
            const SizedBox(height: VinkolSpace.md),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  VinkolDataGrid(
                    data: <VinkolDatum>[
                      VinkolDatum(
                        label: l10n.walletDate,
                        value: walletTimestamp(context, transaction.createdAt),
                        numeric: true,
                      ),
                      VinkolDatum(
                        label: l10n.walletType,
                        value: credit ? l10n.walletCredit : l10n.walletDebit,
                      ),
                      VinkolDatum(
                        label: l10n.walletMethod,
                        value: l10n.walletVinkolWallet,
                      ),
                    ],
                  ),
                  if (transaction.reference.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 17),
                    Divider(height: 1, thickness: 1, color: v.borderSubtle),
                    const SizedBox(height: 17),
                    _Reference(reference: transaction.reference),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The screen's one surface treatment: e0 — a hairline and no shadow.
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return Container(
      padding: const EdgeInsets.all(VinkolSpace.xl),
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brLg,
        border: VinkolElevation.hairline(v),
      ),
      child: child,
    );
  }
}

/// The payment's identifier, beside the one thing anyone does with it.
///
/// It sits inside the details block rather than in a card of its own: it is another attribute
/// of the payment, and a third identical bordered box down the page would have made the
/// screen read as a stack of containers instead of a record.
class _Reference extends StatelessWidget {
  const _Reference({required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                l10n.walletReference,
                style: VinkolType.caption.copyWith(color: v.textTertiary),
              ),
              const SizedBox(height: 3),
              // Mono, because this gets read aloud and transcribed: the face disambiguates
              // 0/O and 1/l/I.
              SelectableText(
                reference,
                style: VinkolType.mono.copyWith(color: v.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(width: VinkolSpace.md),
        Semantics(
          button: true,
          label: l10n.walletCopyReference,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: reference));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: v.surfaceInverse,
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    l10n.walletReferenceCopied,
                    style: VinkolType.body.copyWith(color: v.textInverse),
                  ),
                ),
              );
            },
            // 44pt, so the target is reachable rather than merely visible.
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.copy_outlined, size: 19, color: v.textBrand),
            ),
          ),
        ),
      ],
    );
  }
}
