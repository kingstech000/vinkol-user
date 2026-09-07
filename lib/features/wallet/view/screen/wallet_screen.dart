import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/features/wallet/view/screen/fund_wallet_screen.dart';
import 'package:starter_codes/features/wallet/view/screen/withdraw_screen.dart';
import 'package:starter_codes/features/wallet/view/widget/payment_history_tab.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_balance_hero.dart';
import 'package:starter_codes/features/wallet/view/widget/withdrawal_history_tab.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/features/wallet/view_model/withdrawal_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// The wallet: one balance, and the history of everything that moved it.
///
/// The structure the app already had is kept — balance, then a Payments / Withdrawals split —
/// because the two lists answer different questions ("what have I spent" and "has my money
/// reached my bank") and come from different endpoints.
///
/// The balance scrolls away with the content and the tabs pin under it, so a long history
/// reads without the hero eating a third of a small screen.
class WalletHistoryScreen extends ConsumerStatefulWidget {
  const WalletHistoryScreen({super.key});

  @override
  ConsumerState<WalletHistoryScreen> createState() =>
      _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends ConsumerState<WalletHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() => Future.wait<void>(<Future<void>>[
        ref.read(walletOverviewViewModelProvider.notifier).refreshData(),
        ref.read(withdrawalProvider.notifier).refreshData(),
      ]);

  Future<void> _addMoney() async {
    final bool? funded = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const FundWalletScreen()),
    );
    if (funded == true && mounted) await _refresh();
  }

  Future<void> _withdraw() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const WithdrawScreen()),
    );
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final WalletOverviewState overview =
        ref.watch(walletOverviewViewModelProvider);
    final WithdrawalState withdrawals = ref.watch(withdrawalProvider);
    // Measured, not guessed: the pinned header has to grow with the user's text-size setting
    // or the tab labels clip at 2.0x (D-04). The track is a 22pt-taller label inside 4pt of
    // padding, plus the 8pt gap under it.
    final double tabsExtent =
        MediaQuery.textScalerOf(context).scale(VinkolType.label.fontSize!) +
            22 +
            VinkolSpace.xs * 2 +
            VinkolSpace.sm;

    return Scaffold(
      backgroundColor: v.canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: v.brand,
          backgroundColor: v.surface,
          onRefresh: _refresh,
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool _) => <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    VinkolSpace.pageMargin,
                    VinkolSpace.sm,
                    VinkolSpace.pageMargin,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.walletTitle,
                        style: VinkolType.h1.copyWith(color: v.textPrimary),
                      ),
                      const SizedBox(height: VinkolSpace.lg),
                      WalletBalanceHero(
                        balance: overview.walletBalance,
                        onAddMoney: _addMoney,
                        onWithdraw: _withdraw,
                      ),
                      VinkolSectionHeader(label: l10n.walletHistory),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedTabs(
                  extent: tabsExtent,
                  background: v.canvas,
                  child: VinkolTabBar(
                    controller: _tabController,
                    labels: <String>[
                      l10n.walletTabPayments,
                      l10n.walletTabWithdrawals,
                    ],
                  ),
                ),
              ),
            ],
            body: Padding(
              padding: const EdgeInsets.only(top: VinkolSpace.md),
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  PaymentHistoryTab(
                    history: overview.withdrawalHistory,
                    onRetry: _refresh,
                    onAddMoney: _addMoney,
                  ),
                  WithdrawalHistoryTab(
                    history: withdrawals.withdrawalHistory,
                    onRetry: _refresh,
                    onWithdraw: _withdraw,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pins the tab bar under the balance. It carries the canvas with it so rows scrolling
/// underneath do not show through.
class _PinnedTabs extends SliverPersistentHeaderDelegate {
  const _PinnedTabs({
    required this.child,
    required this.background,
    required this.extent,
  });

  final Widget child;
  final Color background;

  /// Measured against the active text scale by the caller — a sliver delegate has no context
  /// of its own to measure with.
  final double extent;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: background,
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(
        VinkolSpace.pageMargin,
        0,
        VinkolSpace.pageMargin,
        VinkolSpace.sm,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_PinnedTabs oldDelegate) =>
      oldDelegate.child != child ||
      oldDelegate.background != background ||
      oldDelegate.extent != extent;
}
