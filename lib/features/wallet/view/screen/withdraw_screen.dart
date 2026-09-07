import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/extensions/currency_formatter.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/core/market/market_scope.dart';
import 'package:starter_codes/features/wallet/model/bank_model.dart';
import 'package:starter_codes/features/wallet/view/screen/add_bank_screen.dart';
import 'package:starter_codes/features/wallet/view/widget/bank_account_card.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_amount_field.dart';
import 'package:starter_codes/features/wallet/view/widget/withdrawal_confirmation_sheet.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/features/wallet/view_model/withdrawal_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Move money out of the wallet, to the one bank account on the profile.
///
/// There is no note field. The endpoint takes an amount and nothing else, and a box whose
/// contents the server discards is worse than no box at all (D-10).
class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final TextEditingController _amount = TextEditingController();
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() => _touched = true));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletOverviewViewModelProvider.notifier).refreshData();
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  double get _value => CurrencyFormatter.parseAmount(_amount.text);

  String? _errorFor(BuildContext context, double? balance) {
    if (!_touched || _amount.text.isEmpty) return null;
    final l10n = context.l10n;
    final num minimum = MarketScope.market.minimumTransfer;
    if (_value < minimum) {
      return l10n.walletMinimumWithdrawal(MarketFormat.money(minimum));
    }
    if (balance != null && _value > balance) {
      return l10n.walletNotEnoughBalance(MarketFormat.moneyPrecise(balance));
    }
    return null;
  }

  Future<void> _openBankEditor() async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const AddBankScreen()),
    );
    if (saved == true && mounted) {
      await ref.read(withdrawalProvider.notifier).refreshData();
    }
  }

  Future<void> _confirm(UserBank bank) async {
    final l10n = context.l10n;
    final bool? go = await WithdrawalConfirmationSheet.show(
      context,
      amount: _value,
      userBank: bank,
    );
    if (go != true || !mounted) return;

    try {
      await ref.read(withdrawalProvider.notifier).requestWithdrawal(_value);
      if (!mounted) return;
      await ref.read(walletOverviewViewModelProvider.notifier).refreshData();
      if (!mounted) return;
      AppStatusDialogs.showSuccess(
        context,
        l10n.walletWithdrawalRequested,
        l10n.walletWithdrawalRequestedBody,
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        AppStatusDialogs.showError(
            context, l10n.walletCouldNotWithdraw, error.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final WithdrawalState state = ref.watch(withdrawalProvider);
    final double? balance =
        ref.watch(walletOverviewViewModelProvider).walletBalance.valueOrNull;

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: AppBar(
        backgroundColor: v.canvas,
        surfaceTintColor: v.canvas,
        elevation: 0,
        title: Text(l10n.walletWithdraw,
            style: VinkolType.h3.copyWith(color: v.textPrimary)),
      ),
      body: SafeArea(
        top: false,
        child: state.userBank.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(VinkolSpace.pageMargin),
            child: VinkolSkeletonList(count: 2, padding: EdgeInsets.zero),
          ),
          error: (Object error, StackTrace _) => Padding(
            padding: const EdgeInsets.all(VinkolSpace.pageMargin),
            child: VinkolStateView.error(
              title: l10n.walletCouldNotLoadAccount,
              message: error.toString(),
              action: VinkolStateAction(
                label: l10n.commonTryAgain,
                onPressed: () =>
                    ref.read(withdrawalProvider.notifier).refreshData(),
              ),
            ),
          ),
          data: (UserBank? bank) {
            if (bank == null) {
              return Padding(
                padding: const EdgeInsets.all(VinkolSpace.pageMargin),
                child: VinkolStateView.empty(
                  icon: Icons.account_balance_outlined,
                  title: l10n.walletNoBankAccount,
                  message: l10n.walletNoBankAccountBody,
                  action: VinkolStateAction(
                    label: l10n.walletAddBankAccount,
                    onPressed: _openBankEditor,
                  ),
                ),
              );
            }
            return _form(context, bank, balance, state.isLoading);
          },
        ),
      ),
    );
  }

  Widget _form(
    BuildContext context,
    UserBank bank,
    double? balance,
    bool busy,
  ) {
    final l10n = context.l10n;
    final String? error = _errorFor(context, balance);
    final bool ready = error == null && _value > 0;

    return Column(
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
                enabled: !busy,
                error: error,
                hint: balance == null
                    ? null
                    : l10n.walletAvailableAmount(
                        MarketFormat.moneyPrecise(balance)),
              ),
              VinkolSectionHeader(
                label: l10n.walletToAccount,
                action: (label: l10n.walletChange, onTap: _openBankEditor),
              ),
              BankAccountCard(bank: bank, onChangeBank: _openBankEditor),
              const SizedBox(height: VinkolSpace.lg),
              VinkolNotice(
                headline: l10n.walletWithdrawalsAreFinal,
                body: l10n.walletWithdrawalsAreFinalBody,
                icon: Icons.warning_amber_rounded,
                tone: VinkolNoticeTone.warning,
              ),
            ],
          ),
        ),
        VinkolDock(
          label: l10n.walletWithdrawing,
          value: _value > 0 ? MarketFormat.moneyPrecise(_value) : null,
          detail: ready ? null : (error ?? l10n.walletEnterAnAmount),
          actionLabel: l10n.walletConfirmWithdrawal,
          loading: busy,
          onAction: ready && !busy ? () => _confirm(bank) : null,
        ),
      ],
    );
  }
}
