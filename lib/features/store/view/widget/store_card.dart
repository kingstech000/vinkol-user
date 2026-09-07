import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/shop_widgets.dart';

/// One store in a list.
///
/// Shows only what the record holds: name, category area, and whether it is trading. A closed
/// store stays tappable — its menu is still worth reading, and hiding it would look like the
/// shop had vanished.
class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store, required this.onTap});

  final Store store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final bool isOpen = store.openingHours?.isOpenToday() ?? false;

    final String where = <String>[
      if (store.lga?.isNotEmpty ?? false) store.lga!,
      if (store.state?.isNotEmpty ?? false) store.state!,
    ].join(' · ');

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: VinkolSpace.sm),
          padding: const EdgeInsets.all(VinkolSpace.md),
          decoration: BoxDecoration(
            color: v.surface,
            borderRadius: VinkolRadius.brMd,
            border: VinkolElevation.hairline(v),
          ),
          child: Row(
            children: <Widget>[
              ShopImageBlock(
                imageUrl: store.avatar?.imageUrl,
                width: 58,
                height: 58,
                icon: Icons.storefront_outlined,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      store.name ?? '',
                      style: VinkolType.h4.copyWith(color: v.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (where.isNotEmpty) ...<Widget>[
                      const SizedBox(height: VinkolSpace.xxs),
                      Text(
                        where,
                        style: VinkolType.bodyS.copyWith(color: v.textTertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: VinkolSpace.sm),
                    StoreOpenChip(isOpen: isOpen),
                  ],
                ),
              ),
              const SizedBox(width: VinkolSpace.sm),
              Icon(Icons.chevron_right, size: 16, color: v.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
