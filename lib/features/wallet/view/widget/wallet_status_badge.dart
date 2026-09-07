import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// The payment statuses the backend actually returns for a settled payment.
///
/// Four spellings for one state, because the value is written by whichever service settled
/// it. Anything outside this set has *not* succeeded, whatever it is called.
const Set<String> kSuccessfulPaymentStatuses = <String>{
  'success',
  'successful',
  'paid',
  'completed',
};

/// Whether a payment or withdrawal status means the money moved.
bool isSettled(String? status) =>
    status != null &&
    kSuccessfulPaymentStatuses.contains(status.toLowerCase().trim());

/// Which vocabulary a status string is written in.
///
/// A withdrawal is `Approved` or `Rejected`; a payment is `Successful` or `Failed`. Same
/// three outcomes, different words, and using a payment's word on a withdrawal row reads as
/// a bug to anyone who has used a bank app.
enum WalletStatusKind { payment, withdrawal }

/// The status of one payment or withdrawal, as a triple.
///
/// Payment status is **not** a delivery status, so it cannot use [VinkolStatus] and its
/// closed set of six (D-10). It is still bound by D-05: the label leads, the shape carries
/// the signal, colour comes last — so it renders through [VinkolStatusBadge] rather than
/// growing its own coloured pill.
///
/// A status this map does not recognise is shown verbatim in a neutral badge. Inventing a
/// colour for a value the server may have added since this shipped would be a guess, and a
/// guess about whether money moved is the wrong kind of guess.
class WalletStatusBadge extends StatelessWidget {
  const WalletStatusBadge({
    super.key,
    required this.status,
    this.kind = WalletStatusKind.payment,
    this.dense = false,
  });

  final String status;
  final WalletStatusKind kind;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final String s = status.toLowerCase().trim();

    if (kSuccessfulPaymentStatuses.contains(s) || s == 'approved') {
      return VinkolStatusBadge(
        label: kind == WalletStatusKind.withdrawal
            ? l10n.walletStatusApproved
            : l10n.walletStatusSuccessful,
        shape: VinkolStatusShape.filledTick,
        color: v.success,
        ground: v.successGround,
        dense: dense,
      );
    }

    if (s == 'pending' || s == 'processing' || s == 'initiated') {
      return VinkolStatusBadge(
        label: l10n.walletStatusPending,
        shape: VinkolStatusShape.halfFilled,
        color: v.warning,
        ground: v.warningGround,
        dense: dense,
      );
    }

    if (s == 'failed' ||
        s == 'rejected' ||
        s == 'declined' ||
        s == 'reversed' ||
        s == 'cancelled' ||
        s == 'canceled') {
      return VinkolStatusBadge(
        label: kind == WalletStatusKind.withdrawal
            ? l10n.walletStatusRejected
            : l10n.walletStatusFailed,
        shape: VinkolStatusShape.filledAlert,
        color: v.danger,
        ground: v.dangerGround,
        dense: dense,
      );
    }

    return VinkolStatusBadge(
      label: status,
      shape: VinkolStatusShape.hollowSlash,
      color: v.textSecondary,
      ground: v.surfaceAlt,
      dense: dense,
    );
  }
}
