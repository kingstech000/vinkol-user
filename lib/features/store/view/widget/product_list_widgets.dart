import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/utils/map_utils.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/shop_widgets.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Who you are buying from, and where they are.
///
/// The address is the **pickup point** for a shopping order — the user never chooses one —
/// so it is stated here rather than left implicit, and it offers directions because knowing
/// where the shop is is sometimes the reason for opening the screen at all.
class StoreSummaryCard extends StatelessWidget {
  const StoreSummaryCard({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final bool isOpen = store.openingHours?.isOpenToday() ?? false;
    final String? address = store.address;

    return Container(
      padding: const EdgeInsets.all(VinkolSpace.cardPadding),
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brMd,
        border: VinkolElevation.hairline(v),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              ShopImageBlock(
                imageUrl: store.avatar?.imageUrl,
                width: 56,
                height: 56,
                icon: Icons.storefront_outlined,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      store.name ?? '',
                      style: VinkolType.h3.copyWith(color: v.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: VinkolSpace.sm),
                    StoreOpenChip(isOpen: isOpen),
                  ],
                ),
              ),
            ],
          ),
          if (address != null && address.isNotEmpty) ...<Widget>[
            const SizedBox(height: VinkolSpace.md),
            Divider(height: 1, color: v.borderSubtle),
            const SizedBox(height: VinkolSpace.md),
            Row(
              children: <Widget>[
                Icon(Icons.location_on_outlined, size: 18, color: v.brand),
                const SizedBox(width: VinkolSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.storeCollectedFromHere,
                        style:
                            VinkolType.labelS.copyWith(color: v.textTertiary),
                      ),
                      const SizedBox(height: VinkolSpace.xxs),
                      Text(
                        address,
                        style:
                            VinkolType.bodyS.copyWith(color: v.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: VinkolSpace.sm),
                GestureDetector(
                  onTap: () => openGoogleMapsDirections(null, address),
                  behavior: HitTestBehavior.opaque,
                  child: Semantics(
                    button: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: VinkolSpace.md, horizontal: VinkolSpace.xs),
                      child: Text(
                        l10n.storeDirections,
                        style: VinkolType.label.copyWith(color: v.textBrand),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Nothing to show in the catalogue — and which of the two reasons it is.
///
/// A store with no products and a filter that matched nothing look identical if you only say
/// "no results", but only one of them has a way out.
class ProductsEmptyNotice extends StatelessWidget {
  const ProductsEmptyNotice({
    super.key,
    required this.searching,
    required this.onClear,
  });

  final bool searching;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VinkolSpace.xxxl),
      child: VinkolStateView.empty(
        icon: searching ? Icons.search_off : Icons.inventory_2_outlined,
        title: searching ? l10n.storeNoMatches : l10n.storeNothingForSale,
        message:
            searching ? l10n.storeNoMatchesBody : l10n.storeNothingForSaleBody,
        action: VinkolStateAction(
          label: searching ? l10n.storeClearFilters : l10n.storeBrowseStores,
          onPressed:
              searching ? onClear : () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}
