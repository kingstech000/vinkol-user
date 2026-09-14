import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_motion.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/wallet/view/screen/transaction_detail_screen.dart';
import 'package:starter_codes/features/wallet/view/screen/withdraw_screen.dart';
import 'package:starter_codes/features/wallet/view/widget/fund_wallet_sheet.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_ui.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/features/wallet/view_model/withdrawal_view_model.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/widgets/price_text.dart';
import 'package:starter_codes/widgets/state_view.dart';

/// The wallet tab: the balance as the one saturated object on the screen
/// (D-07), the two things you can do with it, and the ledger beneath.
class WalletHistoryScreen extends ConsumerStatefulWidget {
  const WalletHistoryScreen({super.key, this.initialSegment = 0});

  /// 0 for payments, 1 for withdrawals.
  final int initialSegment;

  @override
  ConsumerState<WalletHistoryScreen> createState() =>
      _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends ConsumerState<WalletHistoryScreen> {
  late int _segment = widget.initialSegment.clamp(0, 1);

  @override
  void initState() {
    super.initState();
    // Mounting is not a refresh: use what is cached unless it has gone
    // stale. The withdrawal notifier fetches once on creation and is
    // refreshed after each request, so it needs nothing here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletOverviewViewModelProvider.notifier).fetchIfStale();
    });
  }

  Future<void> _refresh() => Future.wait<void>([
        ref.read(walletOverviewViewModelProvider.notifier).refreshData(),
        ref.read(withdrawalProvider.notifier).refreshData(),
      ]);

  /// Runs a wallet action, or explains why it is unavailable.
  ///
  /// There are no customer wallets outside Nigeria: top-ups are refused server
  /// side and there is nothing to withdraw, so say so here rather than letting
  /// the request fail. The tab is hidden in those markets; this is the guard
  /// for a stale navigation index.
  void _guardWalletAction(VoidCallback action) {
    final market = ref.read(userProvider)?.country ?? Country.ng;
    if (market.hasCustomerWallet) {
      action();
      return;
    }
    AppStatusDialogs.showError(
      context,
      'Wallet unavailable',
      'The wallet is not available in your region. Payments are made by card '
          'at checkout, and refunds go back to the card you paid with.',
    );
  }

  void _fund() =>
      _guardWalletAction(() => showFundDialog(context, ref, mounted));

  void _withdraw() => _guardWalletAction(() {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WithdrawScreen()),
        );
      });

  void _open(WalletEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(entry: entry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(walletOverviewViewModelProvider);
    final withdrawals = ref.watch(withdrawalProvider).withdrawalHistory;

    return Scaffold(
      backgroundColor: VinkolPalette.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: VinkolPalette.brand500,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  VinkolSpace.pageMargin,
                  VinkolSpace.lg,
                  VinkolSpace.pageMargin,
                  VinkolSpace.xl,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.h1(
                        'Wallet',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: VinkolPalette.neutral900,
                        letterSpacing: -0.4,
                      ),
                      Gap.h6,
                      AppText.body(
                        'Top up, pay for deliveries, withdraw to your bank.',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: VinkolPalette.neutral500,
                      ),
                      Gap.h20,
                      _BalanceCard(
                        balance: overview.walletBalance,
                        onFund: _fund,
                        onWithdraw: _withdraw,
                        onRetry: _refresh,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SegmentHeader(
                  child: _Segmented(
                    labels: const ['Payments', 'Withdrawals'],
                    index: _segment,
                    onChanged: (i) => setState(() => _segment = i),
                  ),
                ),
              ),
              if (_segment == 0)
                _Ledger(
                  entries: overview.withdrawalHistory.whenData(
                    (list) => [for (final p in list) WalletEntry.fromPayment(p)],
                  ),
                  emptyIcon: PhosphorIconsRegular.receipt,
                  emptyTitle: 'No payments yet',
                  emptyMessage:
                      'Top-ups and the deliveries you pay for from the wallet will show here.',
                  errorTitle: 'Couldn’t load payments',
                  onRetry: _refresh,
                  onOpen: _open,
                )
              else
                _Ledger(
                  entries: withdrawals.whenData(
                    (resp) =>
                        [for (final w in resp.data) WalletEntry.fromWithdrawal(w)],
                  ),
                  emptyIcon: PhosphorIconsRegular.bank,
                  emptyTitle: 'No withdrawals yet',
                  emptyMessage:
                      'Money you send from the wallet to your bank will show here.',
                  errorTitle: 'Couldn’t load withdrawals',
                  onRetry: _refresh,
                  onOpen: _open,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The balance
// ---------------------------------------------------------------------------

/// The one blue object. Everything on it is white — brand.500 carries nothing
/// lighter at body sizes (brand.100 is 3.69:1) — so hierarchy is size and
/// weight, not tint. Loading, the card is a neutral skeleton of the same
/// height; erroring, it is a neutral surface with a retry. Blue is reserved
/// for a balance the app actually knows.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.onFund,
    required this.onWithdraw,
    required this.onRetry,
  });

  final AsyncValue<double> balance;
  final VoidCallback onFund;
  final VoidCallback onWithdraw;
  final Future<void> Function() onRetry;

  /// There are no customer wallets in Canada, so wallet amounts are naira.
  /// `wallet-balance` returns a bare number with no currency to read.
  static const Currency _currency = Currency.ngn;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: VinkolMotion.respecting(context, VinkolMotion.base),
      switchInCurve: VinkolMotion.enter,
      switchOutCurve: VinkolMotion.exit,
      child: balance.when(
        loading: () => const SkeletonBox(
          key: ValueKey('loading'),
          height: 172,
          borderRadius: VinkolRadius.brMd,
        ),
        error: (_, __) => Container(
          key: const ValueKey('error'),
          padding: const EdgeInsets.all(VinkolSpace.cardPadding),
          decoration: BoxDecoration(
            borderRadius: VinkolRadius.brMd,
            border: Border.all(color: VinkolPalette.neutral200),
          ),
          child: Row(
            children: [
              const Icon(
                PhosphorIconsRegular.wifiSlash,
                size: 20,
                color: VinkolPalette.neutral500,
              ),
              Gap.w12,
              Expanded(
                child: AppText.body(
                  'Couldn’t load your balance.',
                  fontSize: 14,
                  color: VinkolPalette.neutral700,
                ),
              ),
              TextButton(
                onPressed: onRetry,
                child: AppText.button(
                  'Try again',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.brand600,
                ),
              ),
            ],
          ),
        ),
        data: (amount) {
          final money = Money(amount, _currency);
          return Container(
            key: const ValueKey('data'),
            width: double.infinity,
            padding: const EdgeInsets.all(VinkolSpace.xl),
            decoration: const BoxDecoration(
              color: VinkolPalette.brand500,
              borderRadius: VinkolRadius.brMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.caption(
                  'Available balance',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.white,
                ),
                Gap.h6,
                PriceText(
                  money,
                  size: 36,
                  weight: FontWeight.w800,
                  color: VinkolPalette.white,
                  symbolColor: VinkolPalette.white,
                ),
                Gap.h20,
                Row(
                  children: [
                    Expanded(
                      child: _CardAction(
                        label: 'Add money',
                        icon: PhosphorIconsRegular.plus,
                        filled: true,
                        onTap: onFund,
                      ),
                    ),
                    Gap.w10,
                    Expanded(
                      child: _CardAction(
                        label: 'Withdraw',
                        icon: PhosphorIconsRegular.arrowUpRight,
                        filled: false,
                        onTap: onWithdraw,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A pill on the blue card. Filled is white with brand text; the other is a
/// white hairline with white text. Both 44pt tall.
class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? VinkolPalette.brand600 : VinkolPalette.white;
    return Material(
      color: filled ? VinkolPalette.white : Colors.transparent,
      shape: StadiumBorder(
        side: filled
            ? BorderSide.none
            : const BorderSide(color: VinkolPalette.white, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              Gap.w6,
              Flexible(
                child: AppText.button(
                  label,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The two ledgers
// ---------------------------------------------------------------------------

/// Payments · Withdrawals. The selected segment is a white tile with a
/// hairline inside a sunken track, so it reads in grayscale without the
/// weight change.
class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: VinkolPalette.neutral100,
        borderRadius: VinkolRadius.brSm,
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == index,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration:
                        VinkolMotion.respecting(context, VinkolMotion.fast),
                    curve: VinkolMotion.standard,
                    decoration: BoxDecoration(
                      color: i == index
                          ? VinkolPalette.white
                          : Colors.transparent,
                      borderRadius: VinkolRadius.brSm,
                      border: Border.all(
                        color: i == index
                            ? VinkolPalette.neutral200
                            : Colors.transparent,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: AppText.button(
                      labels[i],
                      fontSize: 14,
                      fontWeight:
                          i == index ? FontWeight.w600 : FontWeight.w500,
                      color: i == index
                          ? VinkolPalette.neutral900
                          : VinkolPalette.neutral600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Keeps the segment control at the top while the ledger scrolls under it.
class _SegmentHeader extends SliverPersistentHeaderDelegate {
  _SegmentHeader({required this.child});

  final Widget child;

  static const _height = 44.0 + VinkolSpace.md;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      color: VinkolPalette.white,
      padding: const EdgeInsets.fromLTRB(
        VinkolSpace.pageMargin,
        0,
        VinkolSpace.pageMargin,
        VinkolSpace.md,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_SegmentHeader old) => old.child != child;
}

/// One ledger: rows on one surface, or the skeleton, empty or error view in
/// its place. The scroll view is always scrollable, so pull-to-refresh works
/// over an empty ledger too.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.entries,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.errorTitle,
    required this.onRetry,
    required this.onOpen,
  });

  final AsyncValue<List<WalletEntry>> entries;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final String errorTitle;
  final Future<void> Function() onRetry;
  final ValueChanged<WalletEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    return entries.when(
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: VinkolSpace.pageMargin),
        sliver: SliverToBoxAdapter(
          child: WalletSurface(
            children: List.filled(5, const WalletEntryRowSkeleton()),
          ),
        ),
      ),
      error: (_, __) => _StateSliver(
        child: StateView(
          isError: true,
          icon: PhosphorIconsRegular.wifiSlash,
          title: errorTitle,
          message: 'Check your connection and try again.',
          actionLabel: 'Try again',
          onAction: onRetry,
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return _StateSliver(
            child: StateView(
              icon: emptyIcon,
              title: emptyTitle,
              message: emptyMessage,
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            VinkolSpace.pageMargin,
            0,
            VinkolSpace.pageMargin,
            VinkolSpace.xxxl,
          ),
          sliver: SliverToBoxAdapter(
            child: WalletSurface(
              children: [
                for (final e in list)
                  WalletEntryRow(entry: e, onTap: () => onOpen(e)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// An empty or error view sits just under the segment control, not in the
/// middle of the leftover space, so it reads as the ledger's content.
class _StateSliver extends StatelessWidget {
  const _StateSliver({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: VinkolSpace.huge),
      sliver: SliverToBoxAdapter(child: child),
    );
  }
}
