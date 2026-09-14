import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/store_card.dart';
import 'package:starter_codes/features/store/view/widget/store_ui.dart';
import 'package:starter_codes/features/store/view_model/store_view_model.dart';
import 'package:starter_codes/provider/store_provider.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';

/// The stores the customer can order from, in the region their account is
/// set to. Arriving from a category filters the list to it; the filter is
/// shown as a chip so it can be cleared without going back.
class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({super.key});

  @override
  ConsumerState<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends ConsumerState<StoresScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _adoptSelectedTag());
  }

  /// A category picked on the previous screen arrives through
  /// [selectedTagProvider]; take it once and clear it so it cannot re-fire.
  void _adoptSelectedTag() {
    final tag = ref.read(selectedTagProvider);
    if (tag != null) {
      ref.read(selectedTagProvider.notifier).state = null;
      ref.read(storesViewModelProvider.notifier).filterStoresByTag(tag);
    } else {
      ref.read(storesViewModelProvider.notifier).fetchStoresIfStale();
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      ref
          .read(storesViewModelProvider.notifier)
          .filterStoresBySearch(_searchController.text.trim());
    });
  }

  Future<void> _refresh() =>
      ref.read(storesViewModelProvider.notifier).refreshStores();

  void _clearTag() =>
      ref.read(storesViewModelProvider.notifier).filterStoresByTag(null);

  void _open(Store store) {
    ref.read(currentStoreProvider.notifier).state = store;
    NavigationService.instance.navigateTo(NavigatorRoutes.productListScreen);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(selectedTagProvider, (_, tag) {
      if (tag != null) _adoptSelectedTag();
    });

    final stores = ref.watch(storesViewModelProvider);
    final region = ref.watch(userProvider)?.currentState;
    final tag = ref.watch(storesViewModelProvider.notifier).currentTag;
    final tagName = _tagName(tag);

    return Scaffold(
      appBar: MiniAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                VinkolSpace.pageMargin,
                VinkolSpace.xs,
                VinkolSpace.pageMargin,
                VinkolSpace.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.h1(
                    'Stores near you',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: VinkolPalette.neutral900,
                    letterSpacing: -0.4,
                  ),
                  Gap.h6,
                  AppText.body(
                    region == null || region.isEmpty
                        ? 'Set your location to see stores that deliver to you.'
                        : 'Delivering in $region.',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: VinkolPalette.neutral500,
                  ),
                  Gap.h16,
                  StoreSearchField(
                    controller: _searchController,
                    hint: 'Search stores',
                  ),
                  if (tagName != null) ...[
                    Gap.h12,
                    _FilterChip(label: tagName, onClear: _clearTag),
                  ],
                ],
              ),
            ),
            Expanded(
              child: stores.when(
                data: (response) => response.stores.isEmpty
                    ? RefreshableFill(
                        onRefresh: _refresh,
                        child: StoreStateView(
                          icon: PhosphorIconsRegular.storefront,
                          title: _searchController.text.trim().isNotEmpty
                              ? 'No stores match your search'
                              : tagName != null
                                  ? 'No $tagName stores here yet'
                                  : 'No stores here yet',
                          message: _searchController.text.trim().isNotEmpty
                              ? 'Try a shorter name, or clear the search.'
                              : 'Stores are still signing up in ${region ?? 'your area'}. Pull down to check again.',
                          actionLabel:
                              tagName != null ? 'Show all stores' : null,
                          onAction: tagName != null ? _clearTag : null,
                        ),
                      )
                    : _StoreList(
                        stores: response.stores,
                        onRefresh: _refresh,
                        onOpen: _open,
                      ),
                loading: () => const _StoreListSkeleton(),
                error: (_, __) => RefreshableFill(
                  onRefresh: _refresh,
                  child: StoreStateView(
                    isError: true,
                    icon: PhosphorIconsRegular.wifiSlash,
                    title: 'Couldn’t load stores',
                    message: 'Check your connection and try again.',
                    actionLabel: 'Try again',
                    onAction: _refresh,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The category's display name, from the tag list when it has loaded and
  /// from the value itself when it has not.
  String? _tagName(String? tag) {
    if (tag == null || tag.isEmpty) return null;
    final tags = ref.watch(storeTagsProvider).valueOrNull;
    final match = tags?.where((t) => t.tagValue == tag).firstOrNull;
    if (match != null) return match.name;
    return tag[0].toUpperCase() + tag.substring(1);
  }
}

class _StoreList extends StatelessWidget {
  const _StoreList({
    required this.stores,
    required this.onRefresh,
    required this.onOpen,
  });

  final List<Store> stores;
  final Future<void> Function() onRefresh;
  final ValueChanged<Store> onOpen;

  @override
  Widget build(BuildContext context) {
    final count = stores.length;
    return RefreshIndicator(
      color: VinkolPalette.brand500,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          VinkolSpace.pageMargin,
          0,
          VinkolSpace.pageMargin,
          VinkolSpace.xxxl,
        ),
        children: [
          AppText.caption(
            count == 1 ? '1 store' : '$count stores',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: VinkolPalette.neutral500,
            letterSpacing: 0.3,
          ),
          Gap.h8,
          StoreListSurface(
            children: [
              for (final store in stores)
                StoreCard(store: store, onTap: () => onOpen(store)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoreListSkeleton extends StatelessWidget {
  const _StoreListSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        VinkolSpace.pageMargin,
        VinkolSpace.xxl,
        VinkolSpace.pageMargin,
        0,
      ),
      child: StoreListSurface(
        children: List.filled(6, const StoreCardSkeleton()),
      ),
    );
  }
}

/// The active category. Tapping the cross drops the filter in place.
class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Material(
        color: VinkolPalette.brand50,
        shape: const StadiumBorder(
          side: BorderSide(color: VinkolPalette.brand100),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onClear,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              VinkolSpace.md,
              VinkolSpace.xs + 2,
              VinkolSpace.sm,
              VinkolSpace.xs + 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.caption(
                  label,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.brand600,
                ),
                Gap.w6,
                const Icon(
                  PhosphorIconsRegular.x,
                  size: 14,
                  color: VinkolPalette.brand600,
                  semanticLabel: 'Clear category',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
