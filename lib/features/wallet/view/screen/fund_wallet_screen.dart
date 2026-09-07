import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/extensions/currency_formatter.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/core/market/market_scope.dart';
import 'package:starter_codes/core/market/models.dart';
import 'package:starter_codes/features/booking/view/widget/quote/payment_source_selector.dart';
import 'package:starter_codes/features/payment/view/payment_webview.dart';
import 'package:starter_codes/features/wallet/data/wallet_service.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_amount_field.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Add money to the wallet.
///
/// A screen rather than the bottom sheet this used to be: it carries an amount, a ladder of
/// presets, a payment method and a dock, and a sheet that tall is a screen wearing a
/// costume — one that also loses the amount every time the keyboard resizes it.
///
/// The methods come from the market (`paymentProviders`), minus the wallet itself: funding a
/// wallet from that wallet is not an option in any market. There is no saved-card row here
/// on purpose — the provider collects card details in its own webview and there is no
/// stored-card endpoint to read one back from (D-10).
class FundWalletScreen extends ConsumerStatefulWidget {
  const FundWalletScreen({super.key});

  @override
  ConsumerState<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends ConsumerState<FundWalletScreen> {
  final TextEditingController _amount = TextEditingController();

  /// Null only in the impossible case of a market that offers no way to pay in — the dock
  /// says so rather than the screen throwing in `initState`.
  MarketPaymentProvider? _provider;
  bool _submitting = false;

  /// Only shown once the field has been touched: a form that opens already complaining is
  /// scolding the user for not having typed yet.
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _provider = _providers.isEmpty ? null : _providers.first;
    _amount.addListener(() => setState(() => _touched = true));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  /// Everything the market offers except the wallet — you cannot fund a wallet from itself.
  static List<MarketPaymentProvider> get _providers =>
      MarketScope.market.paymentProviders
          .where((MarketPaymentProvider p) => p.id != kWalletPaymentSourceId)
          .toList(growable: false);

  double get _value => CurrencyFormatter.parseAmount(_amount.text);

  String? _errorFor(BuildContext context) {
    if (!_touched || _amount.text.isEmpty) return null;
    final num minimum = MarketScope.market.minimumTransfer;
    if (_value < minimum) {
      return context.l10n.walletMinimumTopUp(MarketFormat.money(minimum));
    }
    return null;
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    setState(() => _submitting = true);
    try {
      final Map<String, dynamic> data = await ref
          .read(walletServiceProvider)
          .fundWallet(_value, _provider!.id);
      final String? url = data['authorization_url'] as String?;
      if (!mounted) return;

      if (url == null || url.isEmpty) {
        AppStatusDialogs.showError(
            context, l10n.walletAddMoney, l10n.walletCouldNotStartPayment);
        return;
      }

      final bool? paid = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => PaymentWebViewScreen(
            paymentUrl: url,
            orderId: (data['order_id'] ?? '').toString(),
            reference: (data['reference'] ?? data['trxref'] ?? '').toString(),
            isStoreOrder: false,
            isWalletFunding: true,
          ),
        ),
      );

      if (!mounted) return;
      if (paid == true) {
        await ref.read(walletOverviewViewModelProvider.notifier).refreshData();
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        AppStatusDialogs.showError(
            context, l10n.walletAddMoney, l10n.walletCouldNotStartPayment);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final List<num> presets = MarketScope.market.topUpPresets;
    final double? balance =
        ref.watch(walletOverviewViewModelProvider).walletBalance.valueOrNull;
    final String? error = _errorFor(context);
    final bool ready = error == null && _value > 0 && _provider != null;

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: AppBar(
        backgroundColor: v.canvas,
        surfaceTintColor: v.canvas,
        elevation: 0,
        title: Text(l10n.walletAddMoney,
            style: VinkolType.h3.copyWith(color: v.textPrimary)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  VinkolSpace.pageMargin,
                  VinkolSpace.sm,
                  VinkolSpace.pageMargin,
                  VinkolSpace.xxl,
                ),
                children: <Widget>[
                  WalletAmountField(
                    label: l10n.walletAmount,
                    controller: _amount,
                    autofocus: true,
                    enabled: !_submitting,
                    error: error,
                    hint: balance == null || _value <= 0
                        ? null
                        : l10n.walletBalanceAfterTopUp(
                            MarketFormat.moneyPrecise(balance + _value)),
                  ),
                  const SizedBox(height: VinkolSpace.lg),
                  VinkolChipRow(
                    labels: <String>[
                      for (final num amount in presets)
                        MarketFormat.money(amount, decimalDigits: 0),
                    ],
                    selectedIndex: presets.indexOf(_value),
                    onSelected: (int i) {
                      _amount.text = MarketFormat.amount(presets[i]);
                      _amount.selection =
                          TextSelection.collapsed(offset: _amount.text.length);
                    },
                  ),
                  VinkolSectionHeader(label: l10n.walletPayWith),
                  VinkolRowGroup(
                    children: <VinkolRow>[
                      for (final MarketPaymentProvider provider in _providers)
                        VinkolRow(
                          title: provider.name,
                          meta: provider.note,
                          icon: Icons.credit_card_outlined,
                          accentIcon: provider.id == _provider?.id,
                          enabled: !_submitting,
                          trailing: provider.id == _provider?.id
                              ? Icon(Icons.check, size: 19, color: v.brand)
                              : null,
                          onTap: () => setState(() => _provider = provider),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            VinkolDock(
              label: l10n.walletAdding,
              value: _value > 0 ? MarketFormat.moneyPrecise(_value) : null,
              detail: ready ? null : (error ?? l10n.walletEnterAnAmount),
              actionLabel: l10n.walletAddMoney,
              loading: _submitting,
              onAction: ready && !_submitting ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
