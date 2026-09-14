import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_motion.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/cart_bar.dart';
import 'package:starter_codes/features/store/view/widget/product_card.dart';
import 'package:starter_codes/features/store/view/widget/store_header.dart';
import 'package:starter_codes/features/store/view/widget/store_ui.dart';
import 'package:starter_codes/features/store/view_model/product_list_view_model.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';

/// A store's shelf. The store is named once at the top, the products fill
/// the rest, and the basket rides along the bottom once it has anything in
/// it. Search filters what is already loaded — there is no server search
/// inside a store.
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searching = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      final next = _searchController.text.trim().toLowerCase();
      if (next != _query) setState(() => _query = next);
    });
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(productListViewModelProvider.notifier).loadMoreProducts();
    }
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (_searching) {
        _searchFocus.requestFocus();
      } else {
        _searchController.clear();
        _searchFocus.unfocus();
      }
    });
  }

  Future<void> _refresh() =>
      ref.read(productListViewModelProvider.notifier).refreshProducts();

  List<StoreProduct> _filter(List<StoreProduct> products) {
    if (_query.isEmpty) return products;
    return products.where((p) {
      return p.title.toLowerCase().contains(_query) ||
          p.category.toLowerCase().contains(_query) ||
          (p.description ?? '').toLowerCase().contains(_query);
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(currentStoreProvider);
    if (store == null) {
      return Scaffold(
        appBar: MiniAppBar(),
        body: StoreStateView(
          icon: PhosphorIconsRegular.storefront,
          title: 'Pick a store first',
          message: 'Choose a store from the list to see what it sells.',
          actionLabel: 'Back to stores',
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    final products = ref.watch(productListViewModelProvider);

    return Scaffold(
      backgroundColor: VinkolPalette.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(
                  searching: _searching,
                  onBack: () => Navigator.of(context).maybePop(),
                  onToggleSearch: _toggleSearch,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    VinkolSpace.pageMargin,
                    VinkolSpace.sm,
                    VinkolSpace.pageMargin,
                    VinkolSpace.lg,
                  ),
                  child: StoreHeader(store: store),
                ),
                AnimatedSize(
                  duration: VinkolMotion.respecting(context, VinkolMotion.base),
                  curve: VinkolMotion.standard,
                  alignment: Alignment.topCenter,
                  child: _searching
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(
                            VinkolSpace.pageMargin,
                            0,
                            VinkolSpace.pageMargin,
                            VinkolSpace.lg,
                          ),
                          child: StoreSearchField(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            hint: 'Search this store',
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
                const Divider(height: 1, color: VinkolPalette.neutral100),
                Expanded(
                  child: products.when(
                    data: (state) {
                      final all = state.products;
                      final shown = _filter(all);

                      if (all.isEmpty && !state.isLoadingMore) {
                        return RefreshableFill(
                          onRefresh: _refresh,
                          child: const StoreStateView(
                            icon: PhosphorIconsRegular.package,
                            title: 'Nothing on the shelf yet',
                            message:
                                'This store hasn’t listed any products. Pull down to check again.',
                          ),
                        );
                      }

                      if (shown.isEmpty) {
                        return StoreStateView(
                          icon: PhosphorIconsRegular.magnifyingGlass,
                          title:
                              'No matches for “${_searchController.text.trim()}”',
                          message: 'Try another word, or clear the search.',
                          actionLabel: 'Clear search',
                          onAction: _searchController.clear,
                        );
                      }

                      return _ProductGrid(
                        products: shown,
                        total: _query.isEmpty ? all.length : shown.length,
                        loadingMore: state.isLoadingMore,
                        controller: _scrollController,
                        onRefresh: _refresh,
                      );
                    },
                    loading: () => const _ProductGridSkeleton(),
                    error: (_, __) => RefreshableFill(
                      onRefresh: _refresh,
                      child: StoreStateView(
                        isError: true,
                        icon: PhosphorIconsRegular.wifiSlash,
                        title: 'Couldn’t load products',
                        message: 'Check your connection and try again.',
                        actionLabel: 'Try again',
                        onAction: _refresh,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: CartBar(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Back on the start, search toggle on the end. Nothing between them: the
/// store's name is the title and sits directly below.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.searching,
    required this.onBack,
    required this.onToggleSearch,
  });

  final bool searching;
  final VoidCallback onBack;
  final VoidCallback onToggleSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VinkolSpace.pageMargin,
        VinkolSpace.sm,
        VinkolSpace.pageMargin,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleIconButton(
            icon: PhosphorIconsRegular.caretLeft,
            label: 'Back',
            onTap: onBack,
          ),
          CircleIconButton(
            icon: searching
                ? PhosphorIconsRegular.x
                : PhosphorIconsRegular.magnifyingGlass,
            label: searching ? 'Close search' : 'Search this store',
            active: searching,
            onTap: onToggleSearch,
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.products,
    required this.total,
    required this.loadingMore,
    required this.controller,
    required this.onRefresh,
  });

  final List<StoreProduct> products;
  final int total;
  final bool loadingMore;
  final ScrollController controller;
  final Future<void> Function() onRefresh;

  static const _delegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: VinkolSpace.md,
    mainAxisSpacing: VinkolSpace.md,
    childAspectRatio: ProductCard.aspectRatio,
  );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return RefreshIndicator(
      color: VinkolPalette.brand500,
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              VinkolSpace.pageMargin,
              VinkolSpace.lg,
              VinkolSpace.pageMargin,
              VinkolSpace.sm,
            ),
            sliver: SliverToBoxAdapter(
              child: AppText.caption(
                total == 1 ? '1 product' : '$total products',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: VinkolPalette.neutral500,
                letterSpacing: 0.3,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: VinkolSpace.pageMargin,
            ),
            sliver: SliverGrid(
              gridDelegate: _delegate,
              delegate: SliverChildBuilderDelegate(
                (context, index) => ProductCard(product: products[index]),
                childCount: products.length,
              ),
            ),
          ),
          if (loadingMore)
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: VinkolSpace.xl),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: VinkolPalette.brand500,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),
            ),
          // Room for the cart bar, so the last row can scroll clear of it.
          SliverToBoxAdapter(
            child: SizedBox(
              height: CartBar.height + bottomInset + VinkolSpace.xxl,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGridSkeleton extends StatelessWidget {
  const _ProductGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(
            VinkolSpace.pageMargin,
            VinkolSpace.lg,
            VinkolSpace.pageMargin,
            VinkolSpace.sm,
          ),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SkeletonBox(width: 72, height: 12),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: VinkolSpace.pageMargin,
          ),
          sliver: SliverGrid(
            gridDelegate: _ProductGrid._delegate,
            delegate: SliverChildBuilderDelegate(
              (_, __) => const ProductCardSkeleton(),
              childCount: 4,
            ),
          ),
        ),
      ],
    );
  }
}
