import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/features/wallet/model/bank_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// The last look before an irreversible transfer.
///
/// The amount is the one large figure, and the destination is spelled out underneath it in
/// full — a masked account number here would defeat the point of asking someone to check it.
class WithdrawalConfirmationSheet extends StatelessWidget {
  const WithdrawalConfirmationSheet({
    super.key,
    required this.amount,
    required this.userBank,
    required this.onConfirm,
  });

  final double amount;
  final UserBank userBank;
  final VoidCallback onConfirm;

  /// Opens the sheet and resolves true when the user confirms.
  static Future<bool?> show(
    BuildContext context, {
    required double amount,
    required UserBank userBank,
  }) {
    final v = context.vinkol;
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: v.surface,
      shape: const RoundedRectangleBorder(borderRadius: VinkolRadius.brSheet),
      builder: (BuildContext sheetContext) => WithdrawalConfirmationSheet(
        amount: amount,
        userBank: userBank,
        onConfirm: () => Navigator.of(sheetContext).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          VinkolSpace.pageMargin,
          VinkolSpace.xl,
          VinkolSpace.pageMargin,
          VinkolSpace.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.walletReviewWithdrawal,
              style: VinkolType.h3.copyWith(color: v.textPrimary),
            ),
            const SizedBox(height: VinkolSpace.lg),
            Text(
              MarketFormat.moneyPrecise(amount),
              style: VinkolType.numXl.copyWith(color: v.textPrimary),
            ),
            const SizedBox(height: VinkolSpace.lg),
            VinkolDataGrid(
              data: <VinkolDatum>[
                VinkolDatum(label: l10n.walletBank, value: userBank.bankName),
                VinkolDatum(
                  label: l10n.walletAccountNumber,
                  value: userBank.accountNumber,
                  numeric: true,
                ),
                VinkolDatum(
                    label: l10n.walletAccountName, value: userBank.accountName),
              ],
            ),
            const SizedBox(height: VinkolSpace.lg),
            VinkolNotice(
              headline: l10n.walletWithdrawalsAreFinal,
              body: l10n.walletWithdrawalsAreFinalBody,
              icon: Icons.warning_amber_rounded,
              tone: VinkolNoticeTone.warning,
            ),
            const SizedBox(height: VinkolSpace.xl),
            VinkolPrimaryButton(
              label: l10n.walletConfirmWithdrawal,
              onPressed: onConfirm,
            ),
          ],
        ),
      ),
    );
  }
}
