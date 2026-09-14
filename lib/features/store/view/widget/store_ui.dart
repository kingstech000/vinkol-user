import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/search_field.dart';
import 'package:starter_codes/widgets/state_view.dart';

export 'package:starter_codes/widgets/price_text.dart';
export 'package:starter_codes/widgets/search_field.dart';
export 'package:starter_codes/widgets/state_view.dart';

/// The pieces every screen in the shopping flow shares. One definition each,
/// so a price, a stepper or a store's open state looks the same on the list,
/// the detail page and the cart.
///
/// The pieces that turned out not to be store-specific — the price, the
/// search field, the skeleton, the empty/error view — now live in
/// `lib/widgets/` and are re-exported here under the names the store screens
/// already use.

typedef StoreStateView = StateView;
typedef StoreSearchField = SearchField;

// ---------------------------------------------------------------------------
// Money
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Quantity
// ---------------------------------------------------------------------------

/// Minus · count · plus. At one, minus becomes a bin so the customer can see
/// the next tap removes the item rather than guessing.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.canIncrement = true,
    this.compact = false,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool canIncrement;

  /// 32pt tall for tiles and rows; 44pt otherwise.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Visual height can be compact; the tap target never drops under 44pt.
    final height = compact ? 36.0 : 44.0;
    final iconSize = compact ? 16.0 : 20.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: VinkolPalette.white,
        borderRadius: VinkolRadius.brSm,
        border: Border.all(color: VinkolPalette.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: quantity <= 1
                ? PhosphorIconsRegular.trash
                : PhosphorIconsRegular.minus,
            label: quantity <= 1 ? 'Remove' : 'Decrease quantity',
            size: height,
            iconSize: iconSize,
            onTap: onDecrement,
            width: 44,
          ),
          SizedBox(
            width: compact ? 28 : 40,
            child: Center(
              child: Text(
                '$quantity',
                style: TextStyle(
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.neutral900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          _StepButton(
            icon: PhosphorIconsRegular.plus,
            label: 'Increase quantity',
            size: height,
            iconSize: iconSize,
            onTap: canIncrement ? onIncrement : null,
            width: 44,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.size,
    required this.iconSize,
    required this.onTap,
    required this.width,
  });

  final IconData icon;
  final String label;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onTap!();
                }
              : null,
          child: SizedBox(
            width: width,
            height: size,
            child: Icon(
              icon,
              size: iconSize,
              color:
                  enabled ? VinkolPalette.brand600 : VinkolPalette.neutral300,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Store identity
// ---------------------------------------------------------------------------

/// Open or closed as a triple — word, shape, colour (decision D-05). Open is
/// a filled dot; closed is a hollow ring, so the two differ in grayscale.
/// Closed is not an error, so it sits on neutral rather than red.
class StoreOpenPill extends StatelessWidget {
  const StoreOpenPill({super.key, required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? VinkolPalette.successText : VinkolPalette.neutral600;
    final ground =
        isOpen ? VinkolPalette.successGround : VinkolPalette.neutral100;

    return Semantics(
      label: isOpen ? 'Open now' : 'Closed now',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: VinkolSpace.sm,
          vertical: VinkolSpace.xs,
        ),
        decoration: BoxDecoration(
          color: ground,
          borderRadius: VinkolRadius.brFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOpen ? color : Colors.transparent,
                border: Border.all(color: color, width: 1.5),
              ),
            ),
            Gap.w6,
            AppText.caption(
              isOpen ? 'Open' : 'Closed',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

/// A store's logo, drawn bare — no tile behind it — with the storefront
/// glyph standing in when there is none. Photos keep a rounded clip so a
/// square asset does not read as a hard-edged box.
class StoreLogo extends StatelessWidget {
  const StoreLogo({super.key, required this.store, this.size = 56});

  final Store store;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = store.avatar?.imageUrl;
    final hasImage = url != null && url.startsWith('http');

    final fallback = Center(
      child: Icon(
        PhosphorIconsRegular.storefront,
        size: size * 0.45,
        color: VinkolPalette.neutral400,
      ),
    );

    return SizedBox(
      width: size,
      height: size,
      child: hasImage
          ? ClipRRect(
              borderRadius: VinkolRadius.brSm,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                memCacheHeight: 300,
                placeholder: (_, __) => const SizedBox.shrink(),
                errorWidget: (_, __, ___) => fallback,
              ),
            )
          : fallback,
    );
  }
}

/// A product photo, drawn bare with a rounded clip. Photos on transparency
/// (most product shots) sit straight on the surface; a missing one shows the
/// image glyph in its place.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.url,
    this.borderRadius = VinkolRadius.brSm,
    this.iconSize = 28,
  });

  final String url;
  final BorderRadius borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Icon(
        PhosphorIconsRegular.image,
        size: iconSize,
        color: VinkolPalette.neutral300,
      ),
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: url.isEmpty
          ? fallback
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              memCacheHeight: 800,
              placeholder: (_, __) => const SkeletonBox(),
              errorWidget: (_, __, ___) => fallback,
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chrome
// ---------------------------------------------------------------------------

/// A round e0 control for sitting on top of an image — hairline, no shadow.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Filled with the brand when the control is "on" — the search toggle.
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: active ? VinkolPalette.brand500 : VinkolPalette.white,
        shape: CircleBorder(
          side: BorderSide(
            color: active ? VinkolPalette.brand500 : VinkolPalette.neutral200,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 20,
              color: active ? VinkolPalette.white : VinkolPalette.neutral900,
            ),
          ),
        ),
      ),
    );
  }
}
