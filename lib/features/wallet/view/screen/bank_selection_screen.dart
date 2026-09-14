import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/wallet/model/bank_model.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_ui.dart';
import 'package:starter_codes/features/wallet/view_model/withdrawal_view_model.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/search_field.dart';
import 'package:starter_codes/widgets/state_view.dart';

/// A long list with a search on top. Picking a row selects it and returns.
class BankSelectionScreen extends ConsumerStatefulWidget {
  const BankSelectionScreen({super.key});

  @override
  ConsumerState<BankSelectionScreen> createState() =>
      _BankSelectionScreenState();
}

class _BankSelectionScreenState extends ConsumerState<BankSelectionScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _select(Bank bank) {
    ref.read(withdrawalProvider.notifier).selectBank(bank);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(withdrawalProvider);
    final query = _searchController.text.trim().toLowerCase();
    final selected = state.selectedBank;

    return Scaffold(
      appBar: MiniAppBar(title: 'Choose a bank'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                VinkolSpace.pageMargin,
                VinkolSpace.xs,
                VinkolSpace.pageMargin,
                VinkolSpace.md,
              ),
              child: SearchField(
                controller: _searchController,
                hint: 'Search banks',
                autofocus: true,
              ),
            ),
            Expanded(
              child: state.bankList.when(
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VinkolSpace.pageMargin,
                  ),
                  child: WalletSurface(
                    children: List.filled(8, const _BankRowSkeleton()),
                  ),
                ),
                error: (_, __) => StateView(
                  isError: true,
                  icon: PhosphorIconsRegular.wifiSlash,
                  title: 'Couldn’t load banks',
                  message: 'Check your connection and try again.',
                  actionLabel: 'Try again',
                  onAction: ref.read(withdrawalProvider.notifier).refreshBankList,
                ),
                data: (banks) {
                  final shown = query.isEmpty
                      ? banks
                      : banks
                          .where((b) => b.name.toLowerCase().contains(query))
                          .toList();
                  if (shown.isEmpty) {
                    return StateView(
                      icon: PhosphorIconsRegular.magnifyingGlass,
                      title: 'No bank matches',
                      message: 'Try a shorter name, or clear the search.',
                      actionLabel: 'Clear search',
                      onAction: _searchController.clear,
                    );
                  }
                  return ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      VinkolSpace.pageMargin,
                      0,
                      VinkolSpace.pageMargin,
                      VinkolSpace.xxxl,
                    ),
                    children: [
                      WalletSurface(
                        children: [
                          for (final bank in shown)
                            _BankRow(
                              bank: bank,
                              selected: selected?.code == bank.code,
                              onTap: () => _select(bank),
                            ),
                        ],
                      ),
                    ],
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

class _BankRow extends StatelessWidget {
  const _BankRow({
    required this.bank,
    required this.selected,
    required this.onTap,
  });

  final Bank bank;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: VinkolSpace.lg,
            vertical: VinkolSpace.md + 2,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppText.body(
                  bank.name,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: VinkolPalette.neutral900,
                  maxLines: 1,
                ),
              ),
              if (selected) ...[
                Gap.w8,
                const Icon(
                  PhosphorIconsRegular.check,
                  size: 18,
                  color: VinkolPalette.brand600,
                  semanticLabel: 'Selected',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BankRowSkeleton extends StatelessWidget {
  const _BankRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: VinkolSpace.lg,
        vertical: VinkolSpace.lg,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: SkeletonBox(width: 160, height: 14),
      ),
    );
  }
}
