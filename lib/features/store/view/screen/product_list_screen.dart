import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/product_list_widgets.dart';
import 'package:starter_codes/features/store/view/widget/shop_widgets.dart';
import 'package:starter_codes/features/store/view_model/product_list_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// A store and its catalogue.
///
/// The category chips are built from the categories the products actually carry rather than
/// from a fixed menu, so a store that sells one kind of thing gets no chips instead of a row
/// of empty filters.
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      ref.read(productListViewModelProvider.notifier).loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _search.dispose();
    super.dispose();
  }

  List<StoreProduct> _filter(List<StoreProduct> products) {
    return products.where((StoreProduct p) {
      final bool matchesCategory = _category == null || p.category == _category;
      if (!matchesCategory) return false;
      if (_query.isEmpty) return true;
      return p.title.toLowerCase().contains(_query) ||
          p.category.toLowerCase().contains(_query) ||
          (p.description ?? '').toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final Store? store = ref.watch(currentStoreProvider);
    final AsyncValue<ProductListState> products =
        ref.watch(productListViewModelProvider);
    final CartState cart = ref.watch(cartProvider);
    final int cartCount = cart.products
        .fold<int>(0, (int sum, StoreProduct i) => sum + (i.quantity ?? 0));
    final double cartTotal = cart.products.fold<double>(
        0, (double sum, StoreProduct i) => sum + i.price * (i.quantity ?? 0));

    if (store == null) {
      return Scaffold(
        backgroundColor: v.canvas,
        appBar: AppBar(
          backgroundColor: v.canvas,
          surfaceTintColor: v.canvas,
          elevation: 0,
        ),
        body: SafeArea(
          child: VinkolStateView.empty(
            icon: Icons.storefront_outlined,
            title: l10n.storeNoStoreSelected,
            message: l10n.storeNoStoreSelectedBody,
            action: VinkolStateAction(
              label: l10n.storeBrowseStores,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: AppBar(
        backgroundColor: v.canvas,
        surfaceTintColor: v.canvas,
        elevation: 0,
        title: Text(
          store.name ?? l10n.storeStores,
          style: VinkolType.h3.copyWith(color: v.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: products.when(
                loading: () => const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: VinkolSpace.pageMargin),
                  child: VinkolSkeletonList(count: 5),
                ),
                error: (Object error, StackTrace stack) =>
                    VinkolStateView.error(
                  title: l10n.storeCouldNotLoadProducts,
                  message: error.toString(),
                  action: VinkolStateAction(
                    label: l10n.commonTryAgain,
                    onPressed: () => ref
                        .read(productListViewModelProvider.notifier)
                        .refreshProducts(),
                  ),
                ),
                data: (ProductListState state) {
                  final List<StoreProduct> visible = _filter(state.products);
                  final List<String> categories = <String>{
                    for (final StoreProduct p in state.products)
                      if (p.category.isNotEmpty) p.category,
                  }.toList()
                    ..sort();

                  return RefreshIndicator(
                    color: v.brand,
                    onRefresh: () => ref
                        .read(productListViewModelProvider.notifier)
                        .refreshProducts(),
                    child: CustomScrollView(
                      controller: _scroll,
                      slivers: <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: VinkolSpace.pageMargin),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                const SizedBox(height: VinkolSpace.sm),
                                StoreSummaryCard(store: store),
                                const SizedBox(height: VinkolSpace.md),
                                VinkolFormField(
                                  label: l10n.storeSearchThisStore,
                                  hint: l10n.storeSearchThisStoreHint,
                                  controller: _search,
                                  leading: Icon(Icons.search,
                                      size: 19, color: v.textTertiary),
                                  onChanged: (String q) => setState(
                                      () => _query = q.toLowerCase().trim()),
                                ),
                                if (categories.length > 1) ...<Widget>[
                                  const SizedBox(height: VinkolSpace.md),
                                  VinkolChipRow(
                                    labels: <String>[
                                      l10n.storeAll,
                                      ...categories
                                    ],
                                    selectedIndex: _category == null
                                        ? 0
                                        : categories.indexOf(_category!) + 1,
                                    onSelected: (int index) => setState(() =>
                                        _category = index == 0
                                            ? null
                                            : categories[index - 1]),
                                  ),
                                ],
                                VinkolSectionHeader(
                                  label: l10n.storeMenu,
                                  meta: '${visible.length}',
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (visible.isEmpty)
                          SliverToBoxAdapter(
                            child: ProductsEmptyNotice(
                              searching: _query.isNotEmpty || _category != null,
                              onClear: () => setState(() {
                                _query = '';
                                _category = null;
                                _search.clear();
                              }),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: VinkolSpace.pageMargin),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                crossAxisSpacing: VinkolSpace.md,
                                mainAxisSpacing: VinkolSpace.md,
                                mainAxisExtent: 218,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  final StoreProduct product = visible[index];
                                  return ShopProductTile(
                                    title: product.title,
                                    price: product.price,
                                    imageUrl: product.image.imageUrl,
                                    quantityInCart: ref
                                        .read(cartProvider.notifier)
                                        .getProductQuantity(product),
                                    onAdd: () => ref
                                        .read(cartProvider.notifier)
                                        .addProduct(product),
                                    onTap: () =>
                                        NavigationService.instance.navigateTo(
                                      NavigatorRoutes.productDetailScreen,
                                      argument: <String, dynamic>{
                                        'product': product
                                      },
                                    ),
                                  );
                                },
                                childCount: visible.length,
                              ),
                            ),
                          ),
                        if (state.isLoadingMore)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(VinkolSpace.xl),
                              child: Center(
                                  child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )),
                            ),
                          ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: VinkolSpace.xxl),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (cartCount > 0)
              VinkolDock(
                label: l10n.storeInCart(cartCount),
                value: MarketFormat.money(cartTotal),
                actionLabel: l10n.storeViewCart,
                onAction: () => NavigationService.instance
                    .navigateTo(NavigatorRoutes.cartScreen),
              ),
          ],
        ),
      ),
    );
  }
}
