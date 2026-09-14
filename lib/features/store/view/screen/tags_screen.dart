import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_tag_model.dart';
import 'package:starter_codes/features/store/view/widget/store_ui.dart';
import 'package:starter_codes/provider/store_provider.dart';
import 'package:starter_codes/widgets/gap.dart';

/// The front door of shopping: pick a category, get the stores in it. The
/// grid is the whole screen — there is nothing else to decide here.
class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  static const _columns = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(storeTagsProvider);

    return Scaffold(
      backgroundColor: VinkolPalette.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                VinkolSpace.pageMargin,
                VinkolSpace.lg,
                VinkolSpace.pageMargin,
                VinkolSpace.xxl,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.h1(
                      'Shop by category',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: VinkolPalette.neutral900,
                      letterSpacing: -0.4,
                    ),
                    Gap.h6,
                    AppText.body(
                      'Stores near you, delivered by Vinkol.',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: VinkolPalette.neutral500,
                    ),
                  ],
                ),
              ),
            ),
            tags.when(
              data: (list) => list.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: StoreStateView(
                        icon: PhosphorIconsRegular.storefront,
                        title: 'No categories yet',
                        message:
                            'Stores are still setting up in your area. Check back soon.',
                      ),
                    )
                  : _TagGrid(tags: list),
              loading: () => const _TagGridSkeleton(),
              error: (_, __) => SliverFillRemaining(
                hasScrollBody: false,
                child: StoreStateView(
                  isError: true,
                  icon: PhosphorIconsRegular.wifiSlash,
                  title: 'Couldn’t load categories',
                  message: 'Check your connection and try again.',
                  actionLabel: 'Try again',
                  onAction: () => ref.invalidate(storeTagsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagGrid extends ConsumerWidget {
  const _TagGrid({required this.tags});

  final List<StoreTag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        VinkolSpace.pageMargin,
        0,
        VinkolSpace.pageMargin,
        VinkolSpace.xxxl,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: TagsScreen._columns,
          crossAxisSpacing: VinkolSpace.md,
          mainAxisSpacing: VinkolSpace.lg,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _TagTile(
            tag: tags[index],
            onTap: () {
              ref.read(selectedTagProvider.notifier).state =
                  tags[index].tagValue;
              NavigationService.instance
                  .navigateTo(NavigatorRoutes.storesScreen);
            },
          ),
          childCount: tags.length,
        ),
      ),
    );
  }
}

/// A square image and a name. The image sits on the sunken ground so a
/// transparent or slow asset still has an edge.
class _TagTile extends StatelessWidget {
  const _TagTile({required this.tag, required this.onTap});

  final StoreTag tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tag.name,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: VinkolRadius.brMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: VinkolPalette.neutral50,
                    borderRadius: VinkolRadius.brMd,
                    border: Border.all(color: VinkolPalette.neutral100),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: tag.imageUrl,
                    fit: BoxFit.cover,
                    memCacheHeight: 500,
                    placeholder: (_, __) => const SkeletonBox(),
                    errorWidget: (_, __, ___) => Center(
                      child: Icon(
                        _iconFor(tag.tagValue),
                        size: 36,
                        color: VinkolPalette.neutral400,
                      ),
                    ),
                  ),
                ),
              ),
              Gap.h10,
              // Two lines reserved whether or not the name needs them, so
              // every tile in a row keeps the same image height.
              SizedBox(
                height: 40,
                child: AppText.body(
                  tag.name,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.neutral900,
                  maxLines: 2,
                  lineHeight: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(String tagValue) => switch (tagValue) {
        'supermarket' => PhosphorIconsRegular.shoppingCart,
        'beauty' => PhosphorIconsRegular.sparkle,
        'fashion' => PhosphorIconsRegular.tShirt,
        'electronics' => PhosphorIconsRegular.devices,
        'food' => PhosphorIconsRegular.forkKnife,
        'bakery' => PhosphorIconsRegular.cake,
        'pharmacy' => PhosphorIconsRegular.firstAid,
        _ => PhosphorIconsRegular.storefront,
      };
}

class _TagGridSkeleton extends StatelessWidget {
  const _TagGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: VinkolSpace.pageMargin),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: TagsScreen._columns,
          crossAxisSpacing: VinkolSpace.md,
          mainAxisSpacing: VinkolSpace.lg,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: SkeletonBox(
                  width: double.infinity,
                  borderRadius: VinkolRadius.brMd,
                ),
              ),
              Gap.h10,
              const SkeletonBox(width: 96, height: 16),
            ],
          ),
          childCount: 6,
        ),
      ),
    );
  }
}
