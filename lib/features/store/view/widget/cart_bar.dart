import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/design/vinkol_motion.dart';
import 'package:starter_codes/core/design/vinkol_space.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/store/view/widget/store_ui.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/widgets/gap.dart';

/// The basket, pinned to the bottom of any shopping screen while it has
/// something in it. The one saturated object on the screen (decision D-07):
/// what is in it, what it comes to, and the way to checkout.
///
/// Height it occupies is [height] plus the safe-area inset; scrolling
/// content above it pads by that so the last row is never covered.
class CartBar extends ConsumerWidget {
  const CartBar({super.key});

  static const height = 64.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final items = cart.products;
    final count = items.fold<int>(0, (sum, p) => sum + (p.quantity ?? 0));
    final visible = count > 0;

    // The cart is single-store, so every line shares one currency.
    final currency = items.isEmpty ? Currency.ngn : items.first.currency;
    final subtotal = Money(
      items.fold<double>(0, (sum, p) => sum + p.price * (p.quantity ?? 0)),
      currency,
    );

    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1.2),
      duration: VinkolMotion.respecting(context, VinkolMotion.base),
      curve: VinkolMotion.emphasized,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: VinkolMotion.respecting(context, VinkolMotion.fast),
        child: IgnorePointer(
          ignoring: !visible,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              VinkolSpace.pageMargin,
              0,
              VinkolSpace.pageMargin,
              MediaQuery.paddingOf(context).bottom + VinkolSpace.md,
            ),
            child: Semantics(
              button: true,
              label: 'View cart, $count items, ${subtotal.format()}',
              child: Material(
                color: VinkolPalette.brand500,
                borderRadius: VinkolRadius.brMd,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    NavigationService.instance.navigateTo(
                      NavigatorRoutes.cartScreen,
                      argument: {'isFromWebviewClosing': false},
                    );
                  },
                  child: SizedBox(
                    height: height,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: VinkolSpace.lg,
                      ),
                      child: Row(
                        children: [
                          _CountBadge(count: count),
                          Gap.w12,
                          Expanded(
                            child: AppText.body(
                              'View cart',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: VinkolPalette.white,
                            ),
                          ),
                          PriceText(
                            subtotal,
                            size: 16,
                            weight: FontWeight.w700,
                            color: VinkolPalette.white,
                            symbolColor: VinkolPalette.brand100,
                          ),
                          Gap.w8,
                          const Icon(
                            PhosphorIconsRegular.caretRight,
                            size: 16,
                            color: VinkolPalette.brand100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 28),
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: VinkolSpace.sm),
      decoration: const BoxDecoration(
        color: VinkolPalette.brand700,
        borderRadius: VinkolRadius.brSm,
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: VinkolPalette.white,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
