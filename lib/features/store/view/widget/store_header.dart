import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/store_ui.dart';
import 'package:starter_codes/widgets/gap.dart';

/// Who the customer is buying from. Logo, name, open state with today's
/// closing time when the store gave one, and the address. Shared by the
/// product list and the product detail page so the store reads the same on
/// both.
class StoreHeader extends StatelessWidget {
  const StoreHeader({super.key, required this.store, this.dense = false});

  final Store store;

  /// The detail page's version: smaller logo, name at body size.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final name = store.name?.trim();
    final address = store.address?.trim();
    final closes = store.openingHours?.closesTodayAt;
    final hoursLine = store.isOpen
        ? (closes != null ? 'Closes at $closes' : null)
        : 'Closed today';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StoreLogo(store: store, size: dense ? 44 : 56),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dense)
                AppText.body(
                  (name == null || name.isEmpty) ? 'Store' : name,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.neutral900,
                  maxLines: 2,
                )
              else
                AppText.h2(
                  (name == null || name.isEmpty) ? 'Store' : name,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: VinkolPalette.neutral900,
                  maxLines: 2,
                  letterSpacing: -0.2,
                ),
              Gap.h6,
              Row(
                children: [
                  StoreOpenPill(isOpen: store.isOpen),
                  if (hoursLine != null) ...[
                    Gap.w8,
                    Flexible(
                      child: AppText.caption(
                        hoursLine,
                        fontSize: 12,
                        color: VinkolPalette.neutral500,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
              if (address != null && address.isNotEmpty) ...[
                Gap.h6,
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
      ],
    );
  }
}

/// Fixed-height stand-in for the header while the store is still arriving —
/// only the product detail page needs it, the list already has the store.
class StoreHeaderSkeleton extends StatelessWidget {
  const StoreHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox(width: 56, height: 56),
        Gap.w(VinkolSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 160, height: 20),
              Gap.h(8),
              SkeletonBox(width: 72, height: 14),
              Gap.h(8),
              SkeletonBox(width: double.infinity, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
