import 'package:flutter/material.dart';
import 'package:starter_codes/features/wallet/model/bank_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// The account a withdrawal will land in.
///
/// It used to be a gradient card imitating a physical bank card. It is a row now: the
/// saturated register belongs to the balance, and this is a fact the user is checking, not
/// an object to admire. The account number is shown in full and unmasked, because checking
/// it against their bank app is exactly what the screen is asking them to do.
class BankAccountCard extends StatelessWidget {
  const BankAccountCard({
    super.key,
    required this.bank,
    this.onChangeBank,
  });

  final UserBank bank;
  final VoidCallback? onChangeBank;

  @override
  Widget build(BuildContext context) {
    return VinkolRowGroup(
      children: <VinkolRow>[
        VinkolRow(
          title: bank.accountName.isNotEmpty
              ? bank.accountName
              : context.l10n.walletBankAccount,
          meta: '${bank.bankName} · ${bank.accountNumber}',
          icon: Icons.account_balance_outlined,
          accentIcon: true,
          onTap: onChangeBank,
        ),
      ],
    );
  }
}
