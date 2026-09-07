import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_scope.dart';
import 'package:starter_codes/features/wallet/model/bank_model.dart';
import 'package:starter_codes/features/wallet/view/screen/bank_selection_screen.dart';
import 'package:starter_codes/features/wallet/view_model/withdrawal_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Add or replace the bank account withdrawals are paid into.
///
/// Three steps, in the order the API enforces them: choose the bank, type the account number,
/// and let `banks/validate` return the name on the account. **The name is never typed** — it
/// comes back from the bank, and it is the whole point of the check: it is how someone
/// notices they are about to send money to the wrong account.
///
/// The account number's length is market config, not a constant here. Nigeria's NUBAN is ten
/// digits; a market whose accounts are not one fixed-length number leaves it null.
class AddBankScreen extends ConsumerStatefulWidget {
  const AddBankScreen({super.key});

  @override
  ConsumerState<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends ConsumerState<AddBankScreen> {
  final TextEditingController _accountNumber = TextEditingController();
  Bank? _bank;

  int? get _digits => MarketScope.market.bankAccountDigits;

  bool get _numberComplete {
    final String text = _accountNumber.text.trim();
    if (text.isEmpty) return false;
    return _digits == null ? true : text.length == _digits;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(withdrawalProvider.notifier).clearSession();
    });
    _accountNumber.addListener(_onNumberChanged);
    ref.listenManual<Bank?>(
      withdrawalProvider.select((WithdrawalState s) => s.selectedBank),
      (Bank? previous, Bank? next) {
        if (next != previous && mounted) {
          setState(() => _bank = next);
          _onNumberChanged();
        }
      },
    );
  }

  @override
  void dispose() {
    _accountNumber.removeListener(_onNumberChanged);
    _accountNumber.dispose();
    super.dispose();
  }

  /// Validates as soon as there is a bank and a complete number — the user should not have to
  /// press anything to find out whether the account exists.
  void _onNumberChanged() {
    setState(() {});
    if (_bank == null || !_numberComplete) return;
    FocusScope.of(context).unfocus();
    ref
        .read(withdrawalProvider.notifier)
        .validateBank(_accountNumber.text.trim(), _bank!.code);
  }

  /// The name the bank returned, or null if the check has not passed.
  String? _verifiedName(WithdrawalState state) {
    final Map<String, dynamic>? result = state.validationResult.valueOrNull;
    if (result == null || result.isEmpty || result['success'] != true) {
      return null;
    }
    final Object? name = result['data']?['account_name'];
    final String text = (name ?? '').toString().trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save(WithdrawalState state, String accountName) async {
    final notifier = ref.read(withdrawalProvider.notifier);
    final bool replacing = state.userBank.valueOrNull != null;

    if (replacing) {
      await notifier.updateBank(
        _bank!.code,
        _accountNumber.text.trim(),
        accountName,
        _bank!.name,
      );
    } else {
      await notifier.createBank(
        _bank!.code,
        _accountNumber.text.trim(),
        accountName,
        _bank!.name,
      );
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final WithdrawalState state = ref.watch(withdrawalProvider);
    final bool replacing = state.userBank.valueOrNull != null;
    final String? verified = _verifiedName(state);
    final bool checking = state.validationResult.isLoading;
    final Map<String, dynamic>? result = state.validationResult.valueOrNull;
    final bool refused = !checking &&
        result != null &&
        result.isNotEmpty &&
        result['success'] != true;

    return VinkolFormScaffold(
      appBar: AppBar(
        backgroundColor: v.canvas,
        surfaceTintColor: v.canvas,
        elevation: 0,
        title: Text(l10n.walletBankAccount,
            style: VinkolType.h3.copyWith(color: v.textPrimary)),
      ),
      fields: <Widget>[
        const SizedBox(height: VinkolSpace.sm),
        Text(
          l10n.walletBankAccountBody,
          style: VinkolType.body.copyWith(color: v.textSecondary),
        ),
        const SizedBox(height: VinkolSpace.xxl),
        Text(
          l10n.walletBank,
          style: VinkolType.label.copyWith(color: v.textSecondary),
        ),
        const SizedBox(height: VinkolSpace.labelToField),
        state.bankList.when(
          loading: () => const VinkolRowSkeleton(showValue: false),
          error: (Object error, StackTrace _) => VinkolNotice(
            headline: l10n.walletCouldNotLoadBanks,
            body: error.toString(),
            icon: Icons.warning_amber_rounded,
            tone: VinkolNoticeTone.warning,
          ),
          data: (_) => VinkolRowGroup(
            children: <VinkolRow>[
              VinkolRow(
                title: _bank?.name ?? l10n.walletSelectBank,
                icon: Icons.account_balance_outlined,
                accentIcon: _bank != null,
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const BankSelectionScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: VinkolSpace.xxl),
        VinkolFormField(
          label: l10n.walletAccountNumber,
          controller: _accountNumber,
          enabled: _bank != null && !state.isLoading,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            if (_digits != null) LengthLimitingTextInputFormatter(_digits),
          ],
          hint: _digits == null ? null : l10n.walletAccountNumberHint(_digits!),
          helper: _bank == null
              ? l10n.walletSelectBankFirst
              : (checking ? l10n.walletCheckingAccount : null),
          error: refused ? l10n.walletAccountNotVerified : null,
          trailing: checking
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: v.textTertiary),
                )
              : null,
        ),
        if (refused) ...<Widget>[
          const SizedBox(height: VinkolSpace.md),
          Text(
            l10n.walletAccountNotVerifiedBody,
            style: VinkolType.bodyS.copyWith(color: v.textTertiary),
          ),
        ],
        if (verified != null) ...<Widget>[
          const SizedBox(height: VinkolSpace.xxl),
          Text(
            l10n.walletAccountName,
            style: VinkolType.label.copyWith(color: v.textSecondary),
          ),
          const SizedBox(height: VinkolSpace.labelToField),
          VinkolRowGroup(
            children: <VinkolRow>[
              VinkolRow(
                title: verified,
                meta: l10n.walletAccountVerified,
                icon: Icons.verified_outlined,
                accentIcon: true,
                titleMaxLines: 2,
              ),
            ],
          ),
        ],
      ],
      primaryAction: VinkolPrimaryButton(
        label: replacing ? l10n.walletUpdateAccount : l10n.walletSaveAccount,
        loading: state.isLoading,
        onPressed: verified == null || state.isLoading
            ? null
            : () => _save(state, verified),
      ),
    );
  }
}
