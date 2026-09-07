import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/core/market/market_scope.dart';
import 'package:starter_codes/core/market/models.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// The id the API expects for the wallet, in every market.
const String kWalletPaymentSourceId = 'Wallet';

/// Which payment method the order will be charged to, and the picker that changes it.
///
/// All three quote screens grew their own copy of this — the same selector row, the same
/// modal, the same two hardcoded options, the same `postFrameCallback` inside `build` that
/// switched off the wallet when it could not cover the order. It is one widget now, and the
/// options come from the market rather than from the source: Paystack has no Canadian
/// presence and Interac has no Nigerian one, so the list is config and only the UI is global.
class PaymentSourceField extends StatelessWidget {
  const PaymentSourceField({
    super.key,
    required this.selected,
    required this.amount,
    required this.walletBalance,
    required this.onChanged,
  });

  final MarketPaymentProvider selected;

  /// The order total, used to decide whether the wallet can cover it.
  final double amount;

  /// Null while the balance is still loading — the wallet stays selectable, and the server
  /// rejects the charge if it turns out to be short.
  final double? walletBalance;

  final ValueChanged<MarketPaymentProvider> onChanged;

  @override
  Widget build(BuildContext context) {
    final providers = MarketScope.market.paymentProviders;
    final short = !walletCovers(walletBalance, amount);

    return VinkolRow(
      title: selected.name,
      meta: _noteFor(context, selected, short),
      icon: selected.id == kWalletPaymentSourceId
          ? Icons.account_balance_wallet_outlined
          : Icons.credit_card_outlined,
      accentIcon: true,
      onTap: () => _pick(context, providers, short),
    );
  }

  String _noteFor(
      BuildContext context, MarketPaymentProvider provider, bool short) {
    if (provider.id != kWalletPaymentSourceId) return provider.note;
    if (short) return context.l10n.bookingWalletNotEnough;
    if (walletBalance == null) return provider.note;
    return context.l10n
        .bookingWalletBalance(MarketFormat.money(walletBalance!));
  }

  Future<void> _pick(BuildContext context,
      List<MarketPaymentProvider> providers, bool short) async {
    final v = context.vinkol;

    final MarketPaymentProvider? picked =
        await showModalBottomSheet<MarketPaymentProvider>(
      context: context,
      backgroundColor: v.surface,
      shape: const RoundedRectangleBorder(borderRadius: VinkolRadius.brSheet),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              VinkolSpace.pageMargin,
              VinkolSpace.xl,
              VinkolSpace.pageMargin,
              VinkolSpace.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  sheetContext.l10n.commonSelectPaymentMethod,
                  style: VinkolType.h3.copyWith(color: v.textPrimary),
                ),
                const SizedBox(height: VinkolSpace.lg),
                VinkolRowGroup(
                  children: <VinkolRow>[
                    for (final MarketPaymentProvider provider in providers)
                      VinkolRow(
                        title: provider.name,
                        meta: _noteFor(sheetContext, provider, short),
                        icon: provider.id == kWalletPaymentSourceId
                            ? Icons.account_balance_wallet_outlined
                            : Icons.credit_card_outlined,
                        enabled:
                            provider.id != kWalletPaymentSourceId || !short,
                        trailing: provider.id == selected.id
                            ? Icon(Icons.check, size: 19, color: v.brand)
                            : null,
                        onTap: () => Navigator.of(sheetContext).pop(provider),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) onChanged(picked);
  }
}

/// Whether the wallet can pay for an order of [amount].
///
/// A null balance has not loaded yet and is treated as sufficient: blocking the wallet on
/// missing data would push a paying customer to a card they did not need.
bool walletCovers(double? walletBalance, double amount) =>
    walletBalance == null || walletBalance >= amount;

/// The payment source an order should default to.
///
/// Wallet when it can cover the order, otherwise the market's first non-wallet provider.
/// This replaces the `setState` inside `build` that all three screens ran from a
/// `postFrameCallback` — a pure function of the amount and the balance, resolved where it is
/// read rather than written back into screen state a frame later.
MarketPaymentProvider resolvePaymentSource({
  required MarketPaymentProvider? chosen,
  required double? walletBalance,
  required double amount,
}) {
  final providers = MarketScope.market.paymentProviders;
  final MarketPaymentProvider wallet = providers.firstWhere(
    (MarketPaymentProvider p) => p.id == kWalletPaymentSourceId,
    orElse: () => providers.first,
  );
  final MarketPaymentProvider fallback = providers.firstWhere(
    (MarketPaymentProvider p) => p.id != kWalletPaymentSourceId,
    orElse: () => providers.first,
  );

  final MarketPaymentProvider source = chosen ?? wallet;
  if (source.id == kWalletPaymentSourceId &&
      !walletCovers(walletBalance, amount)) {
    return fallback;
  }
  return source;
}
