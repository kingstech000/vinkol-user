import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/wallet/model/bank_model.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_ui.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/price_text.dart';

/// The last look before money leaves: the amount, the account it goes to,
/// and one button. Cancel is a text action so the primary stands alone.
class WithdrawalConfirmationSheet extends StatelessWidget {
  const WithdrawalConfirmationSheet({
    super.key,
    required this.amount,
    required this.userBank,
    required this.onConfirm,
  });

  final Money amount;
  final UserBank userBank;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return WalletSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.h2(
            'Confirm withdrawal',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: VinkolPalette.neutral900,
          ),
          Gap.h4,
          AppText.body(
            'Sent to your bank once approved. This can’t be undone.',
            fontSize: 14,
            color: VinkolPalette.neutral500,
          ),
          Gap.h20,
          PriceText(
            amount,
            prefix: '−',
            size: 34,
            weight: FontWeight.w800,
          ),
          Gap.h16,
          WalletSurface(
            children: [
              BankAccountRow(bank: userBank),
            ],
          ),
          Gap.h24,
          AppButton.primary(
            title: 'Withdraw ${amount.format()}',
            onTap: onConfirm,
          ),
          Gap.h4,
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
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
    );
  }
}
