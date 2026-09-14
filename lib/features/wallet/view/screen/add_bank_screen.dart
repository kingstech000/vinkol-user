import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_motion.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/wallet/model/bank_model.dart';
import 'package:starter_codes/features/wallet/view/screen/bank_selection_screen.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_ui.dart';
import 'package:starter_codes/features/wallet/view_model/withdrawal_view_model.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';

/// Nigerian bank accounts are a bank plus a 10-digit NUBAN, and the account
/// name comes back from the bank — the customer never types it. So: pick the
/// bank, type the number, and the name appears under it when it resolves.
class AddBankScreen extends ConsumerStatefulWidget {
  const AddBankScreen({super.key});

  @override
  ConsumerState<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends ConsumerState<AddBankScreen> {
  static const _accountNumberLength = 10;

  final _accountNumberController = TextEditingController();
  Bank? _selectedBank;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(withdrawalProvider.notifier).clearSession();
    });
    _accountNumberController.addListener(_onAccountNumberChanged);
    ref.listenManual(
      withdrawalProvider.select((state) => state.selectedBank),
      (previous, next) {
        if (next != previous && mounted) {
          setState(() => _selectedBank = next);
          // A bank chosen after the number was typed still needs the lookup.
          _onAccountNumberChanged();
        }
      },
    );
  }

  @override
  void dispose() {
    _accountNumberController.removeListener(_onAccountNumberChanged);
    _accountNumberController.dispose();
    super.dispose();
  }

  void _onAccountNumberChanged() {
    setState(() {});
    final text = _accountNumberController.text;
    if (_selectedBank != null && text.length == _accountNumberLength) {
      FocusScope.of(context).unfocus();
      ref.read(withdrawalProvider.notifier).validateBank(text, _selectedBank!.code);
    }
  }

  Future<void> _chooseBank() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BankSelectionScreen()),
    );
  }

  Future<void> _save(String accountName, bool replacing) async {
    final notifier = ref.read(withdrawalProvider.notifier);
    try {
      if (replacing) {
        await notifier.updateBank(
          _selectedBank!.code,
          _accountNumberController.text,
          accountName,
          _selectedBank!.name,
        );
      } else {
        await notifier.createBank(
          _selectedBank!.code,
          _accountNumberController.text,
          accountName,
          _selectedBank!.name,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        AppStatusDialogs.showError(
          context,
          'Couldn’t save account',
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(withdrawalProvider);
    final validation = state.validationResult;
    final result = validation.valueOrNull;
    final verified = result != null && result.isNotEmpty && result['success'] == true;
    final accountName = verified
        ? (result['data']?['account_name']?.toString() ?? '')
        : '';
    final numberComplete =
        _accountNumberController.text.length == _accountNumberLength;
    final replacing = state.userBank.valueOrNull != null;

    final String? blocker;
    if (_selectedBank == null) {
      blocker = 'Choose a bank first.';
    } else if (!numberComplete) {
      blocker = 'Enter the 10-digit account number.';
    } else if (validation.isLoading) {
      blocker = 'Checking the account…';
    } else if (!verified) {
      blocker = 'We couldn’t confirm that account. Check the number.';
    } else {
      blocker = null;
    }

    return Scaffold(
      appBar: MiniAppBar(title: replacing ? 'Change bank account' : 'Add bank account'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  VinkolSpace.pageMargin,
                  VinkolSpace.lg,
                  VinkolSpace.pageMargin,
                  VinkolSpace.xxl,
                ),
                children: [
                  AppText.body(
                    'Withdrawals are paid to this account. It must be in your name.',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: VinkolPalette.neutral500,
                  ),
                  Gap.h24,
                  const FieldLabel('Bank'),
                  _BankPicker(
                    bank: _selectedBank,
                    banks: state.bankList,
                    onTap: state.bankList.hasError
                        ? ref.read(withdrawalProvider.notifier).refreshBankList
                        : _chooseBank,
                  ),
                  Gap.h20,
                  const FieldLabel('Account number'),
                  TextFormField(
                    controller: _accountNumberController,
                    enabled: !state.isLoading && _selectedBank != null,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(_accountNumberLength),
                    ],
                    style: walletAmountTextStyle.copyWith(letterSpacing: 1.5),
                    decoration: walletFieldDecoration(
                      hint: '0123456789',
                      helperText: _selectedBank == null
                          ? 'Choose a bank to enter the number.'
                          : '10 digits. We’ll look up the account name.',
                      suffixIcon: numberComplete && validation.isLoading
                          ? const FieldSpinner()
                          : numberComplete && verified
                              ? const Icon(
                                  PhosphorIconsFill.checkCircle,
                                  size: 22,
                                  color: VinkolPalette.successText,
                                  semanticLabel: 'Account verified',
                                )
                              : null,
                    ),
                  ),
                  Gap.h12,
                  _VerificationLine(
                    validation: validation,
                    numberComplete: numberComplete,
                    accountName: accountName,
                  ),
                ],
              ),
            ),
            WalletActionBar(
              blocker: blocker,
              child: AppButton.primary(
                title: replacing ? 'Save new account' : 'Save account',
                disable: blocker != null,
                loading: state.isLoading,
                onTap: () => _save(accountName, replacing),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Looks like the field below it, opens the bank list. The caret is the only
/// hint it is a picker, which is enough once the field it sits above says
/// "Choose a bank".
class _BankPicker extends StatelessWidget {
  const _BankPicker({
    required this.bank,
    required this.banks,
    required this.onTap,
  });

  final Bank? bank;
  final AsyncValue<List<Bank>> banks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // First load only; a refresh with a list already in hand stays usable.
    final loading = banks.isLoading && !banks.hasValue;
    final failed = banks.hasError;
    return Material(
      color: VinkolPalette.white,
      shape: const RoundedRectangleBorder(
        borderRadius: VinkolRadius.brSm,
        side: BorderSide(color: VinkolPalette.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: loading ? null : onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            VinkolSpace.md,
            VinkolSpace.md + 2,
            VinkolSpace.md,
            VinkolSpace.md + 2,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppText.body(
                  loading
                      ? 'Loading banks…'
                      : failed
                          ? 'Couldn’t load banks — tap to retry'
                          : bank?.name ?? 'Choose a bank',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: bank == null
                      ? VinkolPalette.neutral400
                      : VinkolPalette.neutral900,
                  maxLines: 1,
                ),
              ),
              Gap.w8,
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: VinkolPalette.brand500,
                  ),
                )
              else
                const Icon(
                  PhosphorIconsRegular.caretRight,
                  size: 18,
                  color: VinkolPalette.neutral400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the bank said about the number, in one line under the field. The
/// name is the useful part; a mismatch is stated, not just coloured.
class _VerificationLine extends StatelessWidget {
  const _VerificationLine({
    required this.validation,
    required this.numberComplete,
    required this.accountName,
  });

  final AsyncValue<Map<String, dynamic>> validation;
  final bool numberComplete;
  final String accountName;

  @override
  Widget build(BuildContext context) {
    Widget line;
    if (!numberComplete) {
      line = const SizedBox.shrink(key: ValueKey('none'));
    } else {
      line = validation.when(
        loading: () => const _Line(
          key: ValueKey('loading'),
          icon: PhosphorIconsRegular.clock,
          text: 'Checking with the bank…',
          color: VinkolPalette.neutral500,
        ),
        error: (e, _) => _Line(
          key: const ValueKey('error'),
          icon: PhosphorIconsRegular.warningCircle,
          text: 'Couldn’t check the account. ${e.toString().replaceFirst('Exception: ', '')}',
          color: VinkolPalette.dangerText,
        ),
        data: (result) {
          if (result.isEmpty) return const SizedBox.shrink(key: ValueKey('empty'));
          if (result['success'] == true) {
            return _Line(
              key: const ValueKey('ok'),
              icon: PhosphorIconsFill.checkCircle,
              text: accountName.isEmpty ? 'Account found.' : accountName,
              color: VinkolPalette.successText,
              strong: true,
            );
          }
          return const _Line(
            key: ValueKey('bad'),
            icon: PhosphorIconsRegular.warningCircle,
            text: 'No account matches that number at this bank.',
            color: VinkolPalette.dangerText,
          );
        },
      );
    }
    return AnimatedSwitcher(
      duration: VinkolMotion.respecting(context, VinkolMotion.fast),
      child: line,
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    this.strong = false,
  });

  final IconData icon;
  final String text;
  final Color color;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 1),
          child: Icon(icon, size: 18, color: color),
        ),
        Gap.w8,
        Expanded(
          child: AppText.body(
            text,
            fontSize: 14,
            fontWeight: strong ? FontWeight.w600 : FontWeight.w500,
            color: color,
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}
