import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/extensions/currency_formatter.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/payment/view/payment_webview.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_ui.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/features/wallet/view_model/withdrawal_view_model.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';

/// There are no customer wallets in Canada, so wallet amounts are always naira.
/// The symbol and decimal places still come from the market layer rather than
/// being written into the screen.
const Currency _walletCurrency = Currency.ngn;
const double _minimumTopUp = 100;
const List<double> _quickAmounts = [1000, 5000, 10000, 20000];

/// Top up the wallet by card. The amount is the only question; the sheet
/// hands off to the payment page and refreshes the balance when it returns.
void showFundDialog(BuildContext context, WidgetRef ref, bool mounted) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FundSheet(
      onSubmit: (amount) => _fundWallet(amount, ref, context, mounted),
    ),
  );
}

class _FundSheet extends StatefulWidget {
  const _FundSheet({required this.onSubmit});

  final Future<void> Function(double amount) onSubmit;

  @override
  State<_FundSheet> createState() => _FundSheetState();
}

class _FundSheetState extends State<_FundSheet> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _pick(double amount) {
    _amountController.text = CurrencyFormatter.formatAmount(amount);
    _amountController.selection = TextSelection.collapsed(
      offset: _amountController.text.length,
    );
  }

  Future<void> _continue() async {
    if (_formKey.currentState?.validate() != true) return;
    final amount = _amountController.numericValue;
    setState(() => _processing = true);
    try {
      await widget.onSubmit(amount);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typed = _amountController.numericValue;
    return WalletSheet(
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.h2(
              'Add money',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: VinkolPalette.neutral900,
            ),
            Gap.h4,
            AppText.body(
              'Paid by card. The balance updates as soon as it goes through.',
              fontSize: 14,
              color: VinkolPalette.neutral500,
            ),
            Gap.h20,
            const FieldLabel('Amount'),
            TextFormField(
              controller: _amountController,
              enabled: !_processing,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyFormatter.amountFormatter],
              style: walletAmountTextStyle,
              decoration: walletFieldDecoration(
                hint: '0',
                prefixText: _walletCurrency.symbol,
                helperText:
                    'Minimum ${const Money(_minimumTopUp, _walletCurrency).format()}',
              ),
              validator: (value) {
                final amount = CurrencyFormatter.parseAmount(value ?? '');
                if (amount <= 0) return null;
                if (amount < _minimumTopUp) {
                  return 'The minimum top-up is '
                      '${const Money(_minimumTopUp, _walletCurrency).format()}.';
                }
                return null;
              },
            ),
            Gap.h12,
            Wrap(
              spacing: VinkolSpace.sm,
              runSpacing: VinkolSpace.sm,
              children: [
                for (final amount in _quickAmounts)
                  _AmountChip(
                    money: Money(amount, _walletCurrency),
                    selected: typed == amount,
                    onTap: _processing ? null : () => _pick(amount),
                  ),
              ],
            ),
            Gap.h24,
            AppButton.primary(
              title: typed >= _minimumTopUp
                  ? 'Continue with ${Money(typed, _walletCurrency).format()}'
                  : 'Continue',
              disable: typed < _minimumTopUp,
              loading: _processing,
              onTap: _continue,
            ),
            Gap.h4,
            Center(
              child: TextButton(
                onPressed: _processing ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: VinkolSpace.lg,
                  ),
                ),
                child: AppText.button(
                  'Cancel',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.neutral600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A preset amount. Selected, it takes the brand tint; otherwise a hairline.
class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.money,
    required this.selected,
    required this.onTap,
  });

  final Money money;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? VinkolPalette.brand50 : VinkolPalette.white,
      shape: RoundedRectangleBorder(
        borderRadius: VinkolRadius.brSm,
        side: BorderSide(
          color: selected ? VinkolPalette.brand100 : VinkolPalette.neutral200,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: VinkolSpace.md,
            vertical: VinkolSpace.sm + 2,
          ),
          child: Text(
            money.format(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  selected ? VinkolPalette.brand600 : VinkolPalette.neutral700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _fundWallet(
    double amount, WidgetRef ref, BuildContext context, bool mounted) async {
  try {
    final walletService = ref.read(walletServiceProvider);
    final data = await walletService.fundWallet(amount, 'Paystack');

    if (data['authorization_url'] != null && mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            paymentUrl: data['authorization_url'],
            orderId: data['order_id'] ?? '',
            reference: data['reference'] ?? data['trxref'] ?? '',
            isStoreOrder: false,
            isWalletFunding: true,
          ),
        ),
      );

      // Only refresh wallet data if payment was completed successfully
      if (mounted && result == true) {
        await ref.read(walletOverviewViewModelProvider.notifier).refreshData();
      }
    } else if (mounted) {
      AppStatusDialogs.showError(context, 'Couldn’t start payment',
          'We couldn’t get a payment link. Please try again.');
    }
  } catch (error) {
    if (mounted) {
      AppStatusDialogs.showError(context, 'Couldn’t start payment',
          error.toString().replaceFirst('Exception: ', ''));
    }
    rethrow;
  }
}
