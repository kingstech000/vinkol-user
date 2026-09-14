import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/store_ui.dart';
import 'package:starter_codes/widgets/gap.dart';

/// One store in the list: logo, name, where it is, and whether it is open —
/// the three things that decide whether to tap. A row, not a card: the list
/// draws one surface and separates rows with hairlines, so six fit a phone.
class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store, required this.onTap});

  final Store store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = store.name?.trim();
    final address = store.address?.trim();

    return Semantics(
      button: true,
      label: '${name ?? 'Store'}, ${store.isOpen ? 'open' : 'closed'}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: VinkolSpace.lg,
              vertical: VinkolSpace.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StoreLogo(store: store, size: 56),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppText.body(
                              (name == null || name.isEmpty) ? 'Store' : name,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: VinkolPalette.neutral900,
                              maxLines: 2,
                            ),
                          ),
                          Gap.w8,
                          StoreOpenPill(isOpen: store.isOpen),
                        ],
                      ),
                      if (address != null && address.isNotEmpty) ...[
                        Gap.h4,
                        AppText.caption(
                          address,
                          fontSize: 13,
                          color: VinkolPalette.neutral500,
                          maxLines: 2,
                          lineHeight: 1.35,
                        ),
                      ],
                    ],
                  ),
                ),
                Gap.w8,
                const Icon(
                  PhosphorIconsRegular.caretRight,
                  size: 16,
                  color: VinkolPalette.neutral400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The row's silhouette while the list loads.
class StoreCardSkeleton extends StatelessWidget {
  const StoreCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VinkolSpace.lg,
        vertical: VinkolSpace.md,
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 56, height: 56),
          Gap.w12,
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 140, height: 16),
                Gap.h(8),
                SkeletonBox(width: double.infinity, height: 12),
                Gap.h(6),
                SkeletonBox(width: 180, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The one white surface the store rows sit on, hairlines between them.
class StoreListSurface extends StatelessWidget {
  const StoreListSurface({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: VinkolPalette.white,
        borderRadius: VinkolRadius.brMd,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(
                height: 1,
                indent: VinkolSpace.lg,
                endIndent: VinkolSpace.lg,
                color: VinkolPalette.neutral100,
              ),
          ],
        ],
      ),
    );
  }
}
