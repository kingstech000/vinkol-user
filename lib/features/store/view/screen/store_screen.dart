import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/model/store_response_model.dart';
import 'package:starter_codes/features/store/view/widget/store_card.dart';
import 'package:starter_codes/features/store/view_model/store_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/provider/store_provider.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// The stores in a category.
///
/// Two filters and nothing more: a text search the API runs, and an "open now" toggle the app
/// can answer from `isOpenToday()`. There is deliberately no sort-by-distance or sort-by-
/// rating, because the store record carries neither and an invented ordering is a lie about
/// which shop is closest.
class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({super.key});

  @override
  ConsumerState<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends ConsumerState<StoresScreen> {
  final TextEditingController _search = TextEditingController();
  bool _openOnly = false;
  String? _appliedTag;

  @override
  void initState() {
    super.initState();
    // The category picked on the previous screen is consumed once, then cleared, so coming
    // back here from a store does not re-filter.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? tag = ref.read(selectedTagProvider);
      if (tag == null) return;
      _appliedTag = tag;
      ref.read(storesViewModelProvider.notifier).filterStoresByTag(tag);
      ref.read(selectedTagProvider.notifier).state = null;
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Store> _visible(List<Store> stores) => _openOnly
      ? stores
          .where((Store s) => s.openingHours?.isOpenToday() ?? false)
          .toList()
      : stores;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final AsyncValue<StoreResponse> stores = ref.watch(storesViewModelProvider);

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: AppBar(
        backgroundColor: v.canvas,
        surfaceTintColor: v.canvas,
        elevation: 0,
        title: Text(_appliedTag ?? l10n.storeStores,
            style: VinkolType.h3.copyWith(color: v.textPrimary)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: VinkolSpace.pageMargin),
              child: Column(
                children: <Widget>[
                  VinkolFormField(
                    label: l10n.storeSearchStores,
                    hint: l10n.storeSearchStoresHint,
                    controller: _search,
                    leading:
                        Icon(Icons.search, size: 19, color: v.textTertiary),
                    textInputAction: TextInputAction.search,
                    onChanged: (String query) => ref
                        .read(storesViewModelProvider.notifier)
                        .filterStoresBySearch(query),
                  ),
                  const SizedBox(height: VinkolSpace.md),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: VinkolChipRow(
                      labels: <String>[l10n.storeAll, l10n.storeOpenNow],
                      selectedIndex: _openOnly ? 1 : 0,
                      onSelected: (int index) =>
                          setState(() => _openOnly = index == 1),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: stores.when(
                loading: () => const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: VinkolSpace.pageMargin),
                  child: VinkolSkeletonList(count: 5),
                ),
                error: (Object error, StackTrace stack) =>
                    VinkolStateView.error(
                  title: l10n.storeCouldNotLoadStores,
                  message: error.toString(),
                  action: VinkolStateAction(
                    label: l10n.commonTryAgain,
                    onPressed: () => ref
                        .read(storesViewModelProvider.notifier)
                        .refreshStores(),
                  ),
                ),
                data: (StoreResponse response) {
                  final List<Store> visible = _visible(response.stores);

                  if (visible.isEmpty) {
                    return VinkolStateView.empty(
                      icon: Icons.storefront_outlined,
                      title: _openOnly
                          ? l10n.storeNothingOpenNow
                          : l10n.storeNoStoresHere,
                      message: _openOnly
                          ? l10n.storeNothingOpenNowBody
                          : l10n.storeNoStoresHereBody,
                      action: VinkolStateAction(
                        label: _openOnly
                            ? l10n.storeShowAllStores
                            : l10n.commonTryAgain,
                        onPressed: () => _openOnly
                            ? setState(() => _openOnly = false)
                            : ref
                                .read(storesViewModelProvider.notifier)
                                .refreshStores(),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: v.brand,
                    onRefresh: () => ref
                        .read(storesViewModelProvider.notifier)
                        .refreshStores(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        VinkolSpace.pageMargin,
                        VinkolSpace.lg,
                        VinkolSpace.pageMargin,
                        VinkolSpace.xxl,
                      ),
                      itemCount: visible.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return VinkolSectionHeader(
                            label: l10n.storeStoreCount(visible.length),
                          );
                        }
                        final Store store = visible[index - 1];
                        return StoreCard(
                          store: store,
                          onTap: () {
                            ref.read(currentStoreProvider.notifier).state =
                                store;
                            NavigationService.instance
                                .navigateTo(NavigatorRoutes.productListScreen);
                          },
                        );
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
