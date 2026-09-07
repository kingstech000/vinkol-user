import 'package:starter_codes/core/market/market_format.dart';

/// Money on a `double`. This is the app's most-used money path — 34 call sites — so it is
/// where the market layer earns most of its keep.
///
/// Symbol, symbol position, decimal count and grouping all come from the active market. Under
/// Nigeria the output is byte-identical to before (`₦2,500`); under Canada the same call
/// renders `CA$2,500.00` with no call site changed.
extension DoubleX on double {
  String toMoney() => MarketFormat.money(this);

  String toMoneyShowFree() => this == 0.0 ? "Free" : toMoney();

  String toMoneyWithoutSymbol() => MarketFormat.amount(this);

  String toMoneyWithSymbol() => toMoney();
}
