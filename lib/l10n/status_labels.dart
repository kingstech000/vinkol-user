import 'package:flutter/widgets.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/l10n/l10n.dart';

/// The closed set of six order statuses, in the reader's language.
///
/// [VinkolStatusStyle] carries an English label so the token layer stays free of a
/// localization dependency, but nothing user-facing should ever render it: Quebec's Charter
/// makes an untranslated status a compliance problem, not a cosmetic one. Every status the
/// UI shows resolves through here.
extension VinkolStatusL10n on VinkolStatus {
  String labelIn(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case VinkolStatus.pending:
        return l10n.statusPending;
      case VinkolStatus.withRider:
        return l10n.statusWithRider;
      case VinkolStatus.withShopper:
        return l10n.statusWithShopper;
      case VinkolStatus.delivered:
        return l10n.statusDelivered;
      case VinkolStatus.cancelled:
        return l10n.statusCancelled;
      case VinkolStatus.unattended:
        return l10n.statusUnattended;
    }
  }
}

/// The status an order is in, or null when the backend sent something outside the set.
///
/// The set is closed on purpose (D-10) — it is exactly the six the API's own switch produces.
/// There is no "finding a rider", no "preparing", no "at pickup" and no "refunded", so the UI
/// must not imply any of them exist. An unrecognised string returns null rather than being
/// coerced into the nearest match, because guessing at a status is worse than admitting the
/// screen does not know one.
VinkolStatus? vinkolStatusFrom(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case 'pending':
      return VinkolStatus.pending;
    case 'with rider':
    case 'withrider':
      return VinkolStatus.withRider;
    case 'with shopper':
    case 'withshopper':
      return VinkolStatus.withShopper;
    case 'delivered':
      return VinkolStatus.delivered;
    case 'cancelled':
    case 'canceled':
      return VinkolStatus.cancelled;
    case 'unattended':
      return VinkolStatus.unattended;
    default:
      return null;
  }
}

/// Where a status sits on the three-step track: accepted, carried, delivered.
///
/// Cancelled and unattended return null — they are not a step short of delivery, they are a
/// different outcome, and drawing them as an unfinished track would promise a completion that
/// is not coming.
int? trackStepFor(VinkolStatus status) {
  switch (status) {
    case VinkolStatus.pending:
      return 1;
    case VinkolStatus.withRider:
    case VinkolStatus.withShopper:
      return 2;
    case VinkolStatus.delivered:
      return 3;
    case VinkolStatus.cancelled:
    case VinkolStatus.unattended:
      return null;
  }
}

/// Whether the order is still in motion — the one that earns the saturated hero.
bool isLiveStatus(VinkolStatus? status) =>
    status == VinkolStatus.pending ||
    status == VinkolStatus.withRider ||
    status == VinkolStatus.withShopper;
