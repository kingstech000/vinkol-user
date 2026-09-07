import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// The balance, and the two things you can do with it.
///
/// This is the wallet's **one saturated object** (D-07). Nothing else on the screen wears the
/// brand: not the tabs, not the rows, not the amounts. The balance is rendered at the exact
/// precision of the market's currency — a wallet is the one place a rounded figure would be
/// a lie.
///
/// The actions stay live in every state, including the failed one. Not knowing your balance
/// is not a reason to be unable to top it up.
class WalletBalanceHero extends StatelessWidget {
  const WalletBalanceHero({
    super.key,
    required this.balance,
    required this.onAddMoney,
    required this.onWithdraw,
  });

  final AsyncValue<double> balance;
  final VoidCallback onAddMoney;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (balance.isLoading && !balance.hasValue) {
      // The hero's own shape, held while the figure arrives, so the screen does not jump
      // when it lands.
      return const VinkolSkeleton(
        height: 186,
        radius: VinkolRadius.brLg,
      );
    }

    final double? value = balance.valueOrNull;

    return VinkolHeroCard(
      eyebrow: value == null
          ? l10n.walletBalanceUnavailable
          : l10n.walletAvailableBalance,
      headline: value == null ? null : MarketFormat.moneyPrecise(value),
      subtitle: value == null ? l10n.walletBalanceUnavailableBody : null,
      actions: <Widget>[
        VinkolHeroAction(
          label: l10n.walletAddMoney,
          icon: Icons.add,
          filled: true,
          onPressed: onAddMoney,
        ),
        VinkolHeroAction(
          label: l10n.walletWithdraw,
          onPressed: onWithdraw,
        ),
      ],
    );
  }
}
