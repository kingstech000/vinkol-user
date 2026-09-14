import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/extensions/currency_formatter.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/wallet/model/bank_model.dart';
import 'package:starter_codes/features/wallet/view/screen/add_bank_screen.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_ui.dart';
import 'package:starter_codes/features/wallet/view/widget/withdrawal_confirmation_sheet.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/features/wallet/view_model/withdrawal_view_model.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/widgets/price_text.dart';
import 'package:starter_codes/widgets/state_view.dart';

/// Move money from the wallet to the customer's bank. Three questions, in
/// order: how much can go, where it goes, how much to send. The button at
/// the bottom says which one is still unanswered.
class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  /// There are no customer wallets in Canada, so wallet amounts are always naira.
  /// The symbol and decimal places still come from the market layer rather than
  /// being written into the screen.
  static const Currency _walletCurrency = Currency.ngn;
  static const double _minimumWithdrawal = 100;

  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletOverviewViewModelProvider.notifier).fetchIfStale();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _refresh() => Future.wait<void>([
        ref.read(withdrawalProvider.notifier).refreshData(),
        ref.read(walletOverviewViewModelProvider.notifier).refreshData(),
      ]);

  Future<void> _editBank() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddBankScreen()),
    );
    if (result == true && mounted) {
      await ref.read(withdrawalProvider.notifier).refreshData();
    }
  }

  void _confirm(double amount, UserBank bank) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => WithdrawalConfirmationSheet(
        amount: Money(amount, _walletCurrency),
        userBank: bank,
        onConfirm: () {
          Navigator.pop(sheetContext);
          _submit(amount);
        },
      ),
    );
  }

  Future<void> _submit(double amount) async {
    try {
      await ref.read(withdrawalProvider.notifier).requestWithdrawal(amount);
      if (!mounted) return;
      _amountController.clear();
      AppStatusDialogs.showSuccess(
        context,
        'Withdrawal requested',
        'It will show as pending in your wallet until the bank confirms it.',
        onClosed: () {
          if (mounted) Navigator.pop(context);
        },
      );
      await _refresh();
    } catch (e) {
      if (mounted) {
        AppStatusDialogs.showError(
          context,
          'Couldn’t request withdrawal',
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final withdrawalState = ref.watch(withdrawalProvider);
    final balance = ref.watch(walletOverviewViewModelProvider).walletBalance;
    final bank = withdrawalState.userBank;

    // The balance is the ceiling: the endpoint that nets off pending and
    // disputed amounts is admin-only, so the server's own check on
    // `/withdraw` is the second line.
    final limit = balance.valueOrNull;
    const currency = _walletCurrency;
    final typed = _amountController.numericValue;
    final busy = withdrawalState.isLoading;

    // What still stands between the customer and the button, in words.
    // Nothing to withdraw comes first: adding a bank would not change it.
    final String? blocker;
    if (limit != null && limit <= 0) {
      blocker = 'Nothing is available to withdraw right now.';
    } else if (bank.isLoading && !bank.hasValue) {
      blocker = 'Checking your bank account…';
    } else if (bank.hasError) {
      blocker = 'Couldn’t load your bank account. Try again above.';
    } else if (bank.valueOrNull == null) {
      blocker = 'Add a bank account to withdraw to.';
    } else if (typed <= 0) {
      blocker = 'Enter an amount to withdraw.';
    } else {
      blocker = null;
    }

    return Scaffold(
      appBar: MiniAppBar(title: 'Withdraw'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: VinkolPalette.brand500,
                onRefresh: _refresh,
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      VinkolSpace.pageMargin,
                      VinkolSpace.lg,
                      VinkolSpace.pageMargin,
                      VinkolSpace.xxl,
                    ),
                    children: [
                      const SectionLabel('AVAILABLE TO WITHDRAW'),
                      _AvailableBlock(balance: balance, currency: currency),
                      Gap.h28,
                      const SectionLabel('TO'),
                      _Destination(
                        bank: bank,
                        onAdd: _editBank,
                        onChange: _editBank,
                        onRetry: _refresh,
                      ),
                      Gap.h28,
                      const FieldLabel('Amount'),
                      TextFormField(
                        controller: _amountController,
                        enabled: !busy,
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyFormatter.amountFormatter],
                        style: walletAmountTextStyle,
                        decoration: walletFieldDecoration(
                          hint: '0',
                          prefixText: currency.symbol,
                          helperText:
                              'Minimum ${const Money(_minimumWithdrawal, currency).format()}',
                        ),
                        validator: (value) {
                          final amount =
                              CurrencyFormatter.parseAmount(value ?? '');
                          if (amount <= 0) return null;
                          if (amount < _minimumWithdrawal) {
                            return 'The minimum withdrawal is '
                                '${const Money(_minimumWithdrawal, currency).format()}.';
                          }
                          if (limit != null && amount > limit) {
                            return 'Only ${Money(limit, currency).format()} '
                                'is available to withdraw.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            WalletActionBar(
              blocker: blocker,
              child: AppButton.primary(
                title: blocker == null
                    ? 'Withdraw ${Money(typed, currency).format()}'
                    : 'Withdraw',
                disable: blocker != null,
                loading: busy,
                onTap: () {
                  final userBank = bank.valueOrNull;
                  if (userBank == null) return;
                  if (_formKey.currentState?.validate() != true) return;
                  _confirm(typed, userBank);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The wallet balance, which is what can be withdrawn.
class _AvailableBlock extends StatelessWidget {
  const _AvailableBlock({required this.balance, required this.currency});

  final AsyncValue<double> balance;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    return balance.when(
      loading: () => const SkeletonBox(height: 76, borderRadius: VinkolRadius.brMd),
      error: (_, __) => const InlineNotice(
        icon: PhosphorIconsRegular.wifiSlash,
        text: 'Couldn’t check your balance. Pull down to try again.',
      ),
      data: (amount) => WalletSurface(
        children: [
          Padding(
            padding: const EdgeInsets.all(VinkolSpace.lg),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: PriceText(
                Money(amount, currency),
                size: 30,
                weight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The bank the money goes to, or the way to add one.
class _Destination extends StatelessWidget {
  const _Destination({
    required this.bank,
    required this.onAdd,
    required this.onChange,
    required this.onRetry,
  });

  final AsyncValue<UserBank?> bank;
  final VoidCallback onAdd;
  final VoidCallback onChange;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return bank.when(
      loading: () => const SkeletonBox(height: 66, borderRadius: VinkolRadius.brMd),
      error: (_, __) => InlineNotice(
        icon: PhosphorIconsRegular.wifiSlash,
        text: 'Couldn’t load your bank account.',
        actionLabel: 'Try again',
        onAction: onRetry,
      ),
      data: (userBank) {
        if (userBank == null) {
          return InlineNotice(
            icon: PhosphorIconsRegular.bank,
            text: 'No bank account yet. Withdrawals are paid to one you add.',
            actionLabel: 'Add',
            onAction: onAdd,
          );
        }
        return WalletSurface(
          children: [
            BankAccountRow(
              bank: userBank,
              trailing: TextButton(
                onPressed: onChange,
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding:
                      const EdgeInsets.symmetric(horizontal: VinkolSpace.sm),
                ),
                child: AppText.button(
                  'Change',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.brand600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
