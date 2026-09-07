import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/features/wallet/model/bank_model.dart';
import 'package:starter_codes/features/wallet/view_model/withdrawal_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Pick the bank the account belongs to.
///
/// The list runs to a few hundred entries in Nigeria, so it is searched rather than scrolled
/// and built lazily. Selecting one writes it to the withdrawal notifier and pops — the caller
/// listens rather than reading a result, because the account-number field validates against
/// the choice as soon as it lands.
class BankSelectionScreen extends ConsumerStatefulWidget {
  const BankSelectionScreen({super.key});

  @override
  ConsumerState<BankSelectionScreen> createState() =>
      _BankSelectionScreenState();
}

class _BankSelectionScreenState extends ConsumerState<BankSelectionScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Bank> _matching(List<Bank> banks) {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return banks;
    return banks
        .where((Bank b) => b.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final AsyncValue<List<Bank>> banks = ref.watch(withdrawalProvider).bankList;

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: AppBar(
        backgroundColor: v.canvas,
        surfaceTintColor: v.canvas,
        elevation: 0,
        title: Text(l10n.walletSelectBank,
            style: VinkolType.h3.copyWith(color: v.textPrimary)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                VinkolSpace.pageMargin,
                VinkolSpace.sm,
                VinkolSpace.pageMargin,
                VinkolSpace.lg,
              ),
              child: VinkolFormField(
                label: l10n.walletSearchBanks,
                controller: _search,
                leading: Icon(Icons.search, size: 19, color: v.textTertiary),
                onChanged: (String value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: banks.when(
                loading: () => const VinkolSkeletonList(
                  padding:
                      EdgeInsets.symmetric(horizontal: VinkolSpace.pageMargin),
                ),
                error: (Object error, StackTrace _) => Padding(
                  padding: const EdgeInsets.all(VinkolSpace.pageMargin),
                  child: VinkolStateView.error(
                    title: l10n.walletCouldNotLoadBanks,
                    message: error.toString(),
                    action: VinkolStateAction(
                      label: l10n.commonTryAgain,
                      onPressed: () =>
                          ref.read(withdrawalProvider.notifier).refreshData(),
                    ),
                  ),
                ),
                data: (List<Bank> all) {
                  final List<Bank> list = _matching(all);
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(VinkolSpace.pageMargin),
                      child: VinkolStateView.empty(
                        icon: Icons.search_off_outlined,
                        title: l10n.walletNoBanksFound,
                        message: l10n.walletNoBanksFoundBody,
                        action: VinkolStateAction(
                          label: l10n.walletSearchBanks,
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      VinkolSpace.pageMargin,
                      0,
                      VinkolSpace.pageMargin,
                      VinkolSpace.xxl,
                    ),
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int i) => VinkolRow(
                      title: list[i].name,
                      showDivider: i > 0,
                      onTap: () {
                        ref
                            .read(withdrawalProvider.notifier)
                            .selectBank(list[i]);
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
