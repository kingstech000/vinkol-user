import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/utils/failure_kind.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/features/delivery/view/screen/download_report_screen.dart';
import 'package:starter_codes/features/delivery/view/widget/delivery_list_view.dart';
import 'package:starter_codes/features/delivery/view_model/delivery_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/l10n/status_labels.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Delivery records — two order types, two tabs.
///
/// Store orders are not a variation on a courier booking; they have their own lifecycle (a
/// shopper gathers the order before a rider is involved) and their own status vocabulary, so
/// they get their own tab rather than a filter chip.
class DeliveryScreen extends ConsumerStatefulWidget {
  const DeliveryScreen({super.key});

  @override
  ConsumerState<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends ConsumerState<DeliveryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  /// Only a paid order is a record. An abandoned checkout is not something the user did.
  static const Set<String> _paidStatuses = <String>{
    'success',
    'successful',
    'paid',
    'completed',
  };

  /// Null means "All". The set is closed (D-10), so the filter cannot offer a status the
  /// backend never returns.
  VinkolStatus? _filter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deliveryViewModelProvider).fetchPackageDeliveries();
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _filter = null);
      if (_tabController.index == 0) {
        ref.read(deliveryViewModelProvider).fetchPackageDeliveries();
      } else {
        ref.read(deliveryViewModelProvider).fetchStoreDeliveries();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// The statuses a store order can actually reach differ from a courier booking's, so the
  /// chips differ too rather than showing filters that would always come back empty.
  List<VinkolStatus> _statusesFor(bool storeOrders) => <VinkolStatus>[
        VinkolStatus.pending,
        storeOrders ? VinkolStatus.withShopper : VinkolStatus.withRider,
        VinkolStatus.delivered,
        VinkolStatus.cancelled,
      ];

  bool _isPaid(DeliveryModel d) =>
      _paidStatuses.contains(d.paymentStatus?.toLowerCase().trim());

  /// The filter, but only if the tab on screen actually offers it.
  ///
  /// A swipe changes the tab index before the settle listener clears the filter, so for a
  /// frame the chips are rebuilt from the new tab's statuses while the old tab's filter is
  /// still applied — which showed "nothing with that status" under a chip row that said All.
  VinkolStatus? _effectiveFilter(bool storeOrders) =>
      _statusesFor(storeOrders).contains(_filter) ? _filter : null;

  List<DeliveryModel> _visible(List<DeliveryModel> all, bool storeOrders) {
    final List<DeliveryModel> paid = all.where(_isPaid).toList();
    final VinkolStatus? filter = _effectiveFilter(storeOrders);
    if (filter == null) return paid;
    return paid
        .where((DeliveryModel d) => vinkolStatusFrom(d.status) == filter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final DeliveryViewModel model = ref.watch(deliveryViewModelProvider);

    return Scaffold(
      backgroundColor: v.canvas,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                VinkolSpace.pageMargin,
                VinkolSpace.lg,
                VinkolSpace.pageMargin,
                VinkolSpace.md,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(l10n.deliveryRecords,
                        style: VinkolType.h1.copyWith(color: v.textPrimary)),
                  ),
                  Semantics(
                    button: true,
                    label: l10n.deliveryDownloadReport,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const DownloadReportScreen(),
                        ),
                      ),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(Icons.file_download_outlined,
                            size: 21, color: v.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: VinkolSpace.pageMargin),
              child: VinkolTabBar(
                controller: _tabController,
                labels: <String>[
                  l10n.deliveryDeliveries,
                  l10n.deliveryStoreOrders,
                ],
              ),
            ),
            const SizedBox(height: VinkolSpace.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: VinkolSpace.pageMargin),
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (BuildContext context, Widget? child) {
                  final bool storeOrders = _tabController.index == 1;
                  final List<VinkolStatus> statuses = _statusesFor(storeOrders);
                  final VinkolStatus? active = _effectiveFilter(storeOrders);
                  return VinkolChipRow(
                    labels: <String>[
                      l10n.deliveryAll,
                      for (final VinkolStatus s in statuses) s.labelIn(context),
                    ],
                    selectedIndex:
                        active == null ? 0 : statuses.indexOf(active) + 1,
                    onSelected: (int i) => setState(
                        () => _filter = i == 0 ? null : statuses[i - 1]),
                  );
                },
              ),
            ),
            const SizedBox(height: VinkolSpace.sm),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  _Tab(
                    loading: model.isLoadingPackageDeliveries,
                    error: model.packageDeliveryError,
                    all: model.packageDeliveries,
                    visible: _visible(model.packageDeliveries, false),
                    isStoreOrders: false,
                    filtered: _effectiveFilter(false) != null,
                    onClearFilter: () => setState(() => _filter = null),
                    onRetry: () => ref
                        .read(deliveryViewModelProvider)
                        .fetchPackageDeliveries(forceRefresh: true),
                    onRefresh: () => ref
                        .read(deliveryViewModelProvider)
                        .refreshOrders(OrderTabType.packageDelivery),
                    onEmptyAction: () =>
                        ref.read(navigationIndexProvider.notifier).state = 0,
                  ),
                  _Tab(
                    loading: model.isLoadingStoreDeliveries,
                    error: model.storeDeliveryError,
                    all: model.storeDeliveries,
                    visible: _visible(model.storeDeliveries, true),
                    isStoreOrders: true,
                    filtered: _effectiveFilter(true) != null,
                    onClearFilter: () => setState(() => _filter = null),
                    onRetry: () => ref
                        .read(deliveryViewModelProvider)
                        .fetchStoreDeliveries(forceRefresh: true),
                    onRefresh: () => ref
                        .read(deliveryViewModelProvider)
                        .refreshOrders(OrderTabType.storeDelivery),
                    onEmptyAction: () =>
                        ref.read(navigationIndexProvider.notifier).state = 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.loading,
    required this.error,
    required this.all,
    required this.visible,
    required this.isStoreOrders,
    required this.filtered,
    required this.onClearFilter,
    required this.onRetry,
    required this.onRefresh,
    required this.onEmptyAction,
  });

  final bool loading;
  final String? error;
  final List<DeliveryModel> all;
  final List<DeliveryModel> visible;
  final bool isStoreOrders;
  final bool filtered;
  final VoidCallback onClearFilter;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final VoidCallback onEmptyAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (loading && all.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: VinkolSpace.pageMargin),
        child: VinkolSkeletonList(shape: VinkolSkeletonShape.record),
      );
    }

    if (error != null) {
      // An offline failure is the user's to fix, so it gets the offline state rather than a
      // server error with a retry that cannot work.
      return looksOffline(error)
          ? VinkolStateView.offline(onRetry: onRetry)
          : VinkolStateView.error(
              title: l10n.deliveryCouldNotLoad,
              message: error!.trim().isNotEmpty
                  ? error!.trim()
                  : l10n.deliveryCouldNotLoadBody,
              action: VinkolStateAction(
                  label: l10n.commonTryAgain, onPressed: onRetry),
            );
    }

    if (visible.isEmpty) {
      if (filtered) {
        return VinkolStateView.empty(
          icon: Icons.filter_alt_off_outlined,
          title: l10n.deliveryNoneWithThatStatus,
          message: l10n.deliveryNoneWithThatStatusBody,
          action: VinkolStateAction(
            label: l10n.deliveryShowAll,
            onPressed: onClearFilter,
          ),
        );
      }
      return VinkolStateView.empty(
        icon: isStoreOrders
            ? Icons.storefront_outlined
            : Icons.local_shipping_outlined,
        title: isStoreOrders
            ? l10n.deliveryNoStoreOrdersYet
            : l10n.deliveryNoDeliveriesYet,
        message: isStoreOrders
            ? l10n.deliveryNoStoreOrdersYetBody
            : l10n.deliveryNoDeliveriesYetBody,
        action: VinkolStateAction(
          label: isStoreOrders
              ? l10n.storeBrowseStores
              : l10n.deliverySendAPackage,
          onPressed: onEmptyAction,
        ),
      );
    }

    return DeliveryListView(
      deliveries: visible,
      isStoreOrders: isStoreOrders,
      onRefresh: onRefresh,
    );
  }
}
