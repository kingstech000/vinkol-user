import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/failure_kind.dart';
import 'package:starter_codes/features/wallet/model/withdrawal_model.dart';
import 'package:starter_codes/features/wallet/view/widget/payment_history_tab.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_rows.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// The Withdrawals tab: requests to move money out to a bank account.
class WithdrawalHistoryTab extends StatelessWidget {
  const WithdrawalHistoryTab({
    super.key,
    required this.history,
    required this.onRetry,
    required this.onWithdraw,
  });

  final AsyncValue<WithdrawalResponse> history;
  final VoidCallback onRetry;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (history.isLoading && !history.hasValue) {
      return const VinkolSkeletonList(padding: kWalletTabPadding);
    }

    if (history.hasError && !history.hasValue) {
      // An offline failure is the user's to fix, so it gets the offline state rather than a
      // server error with a retry that cannot work.
      return WalletTabFrame(
        child: looksOffline(history.error)
            ? VinkolStateView.offline(onRetry: onRetry)
            : VinkolStateView.error(
                title: l10n.walletCouldNotLoadWithdrawals,
                message: history.error.toString(),
                action: VinkolStateAction(
                  label: l10n.commonTryAgain,
                  onPressed: onRetry,
                ),
              ),
      );
    }

    final List<Withdrawal> list =
        history.valueOrNull?.data ?? const <Withdrawal>[];
    if (list.isEmpty) {
      return WalletTabFrame(
        child: VinkolStateView.empty(
          icon: Icons.account_balance_outlined,
          title: l10n.walletNoWithdrawals,
          message: l10n.walletNoWithdrawalsBody,
          action: VinkolStateAction(
            label: l10n.walletWithdraw,
            onPressed: onWithdraw,
          ),
        ),
      );
    }

    return ListView(
      padding: kWalletTabPadding,
      children: <Widget>[
        VinkolRowGroup(
          children: <VinkolRow>[
            for (final Withdrawal withdrawal in list)
              walletWithdrawalRow(context, withdrawal),
          ],
        ),
      ],
    );
  }
}
