import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/utils/failure_kind.dart';
import 'package:starter_codes/features/wallet/model/payment_history_model.dart';
import 'package:starter_codes/features/wallet/view/screen/transaction_detail_screen.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_rows.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Padding shared by both history tabs. The bottom inset clears the Pod, which floats over
/// the body rather than sitting under it.
const EdgeInsets kWalletTabPadding = EdgeInsets.fromLTRB(
  VinkolSpace.pageMargin,
  0,
  VinkolSpace.pageMargin,
  VinkolPod.bodyInset,
);

/// Keeps every state scrollable, so pull-to-refresh still works on an empty or failed tab
/// and the enclosing [NestedScrollView] always has an inner scrollable to drive.
class WalletTabFrame extends StatelessWidget {
  const WalletTabFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: kWalletTabPadding,
      children: <Widget>[child],
    );
  }
}

/// The Payments tab: everything that moved money into or out of the wallet.
class PaymentHistoryTab extends StatelessWidget {
  const PaymentHistoryTab({
    super.key,
    required this.history,
    required this.onRetry,
    required this.onAddMoney,
  });

  final AsyncValue<List<PaymentHistory>> history;
  final VoidCallback onRetry;
  final VoidCallback onAddMoney;

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
                title: l10n.walletCouldNotLoadPayments,
                message: history.error.toString(),
                action: VinkolStateAction(
                  label: l10n.commonTryAgain,
                  onPressed: onRetry,
                ),
              ),
      );
    }

    final List<PaymentHistory> list = history.valueOrNull ?? <PaymentHistory>[];
    if (list.isEmpty) {
      return WalletTabFrame(
        child: VinkolStateView.empty(
          icon: Icons.receipt_long_outlined,
          title: l10n.walletNoPayments,
          message: l10n.walletNoPaymentsBody,
          action: VinkolStateAction(
            label: l10n.walletAddMoney,
            onPressed: onAddMoney,
          ),
        ),
      );
    }

    return ListView(
      padding: kWalletTabPadding,
      children: <Widget>[
        VinkolRowGroup(
          children: <VinkolRow>[
            for (final PaymentHistory payment in list)
              walletPaymentRow(
                context,
                payment,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        TransactionDetailScreen(transaction: payment),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
