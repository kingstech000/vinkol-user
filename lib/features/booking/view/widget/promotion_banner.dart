import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/core/utils/textstyles.dart';
import 'package:starter_codes/widgets/gap.dart';

/// The loyalty promotion: a soft violet gradient card, title and subtitle on
/// the start side, a gift illustration bleeding off the end edge with a
/// tilted badge over it. One layout for both states — earned and in
/// progress — so only the copy and the badge change. Compact enough to sit
/// below the quick actions without pushing the screen into a scroll.
class PromotionBanner extends StatelessWidget {
  final bool hasPromotion;
  final int completedBookings;
  final int requiredBookings;
  final int discountPercentage;
  final VoidCallback? onTap;

  const PromotionBanner({
    super.key,
    required this.hasPromotion,
    this.completedBookings = 0,
    this.requiredBookings = 3,
    this.discountPercentage = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (hasPromotion) {
      return _GiftCard(
        title: '$discountPercentage% off for you',
        highlight: '$discountPercentage%',
        subtitle: 'Valid on your next booking.\nBook now !!!',
        badge: '$discountPercentage%',
        semanticsLabel:
            'Reward unlocked. $discountPercentage percent off your next booking. Book now.',
        onTap: onTap,
      );
    }

    final remaining = requiredBookings - completedBookings;
    final remainingLabel =
        remaining == 1 ? '1 more booking' : '$remaining more bookings';
    return _GiftCard(
      title: 'Unlock $discountPercentage% off',
      highlight: '$discountPercentage%',
      subtitle: 'Complete $remainingLabel to claim it.',
      badge: '$completedBookings/$requiredBookings',
      semanticsLabel:
          '$remainingLabel to unlock $discountPercentage percent off. '
          '$completedBookings of $requiredBookings bookings done. Start booking.',
      onTap: onTap,
    );
  }
}

class _GiftCard extends StatelessWidget {
  const _GiftCard({
    required this.title,
    required this.highlight,
    required this.subtitle,
    required this.badge,
    required this.semanticsLabel,
    this.onTap,
  });

  final String title;

  /// The substring of [title] set in the brand blue — the discount figure.
  final String highlight;
  final String subtitle;
  final String badge;
  final String semanticsLabel;
  final VoidCallback? onTap;

  /// Width kept clear of text for the illustration and its badge.
  static const double _artWidth = 120;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Semantics(
        button: true,
        label: semanticsLabel,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            // The one place the promo hue is allowed a gradient: it is the
            // reward surface, and the gradient is the two promo steps.
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  VinkolPalette.promoFill,
                  Color.fromARGB(255, 53, 41, 73)
                ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  // Text. The end-side gap is reserved for the art.
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      20.w,
                      20.h,
                      0,
                      20.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _HighlightedTitle(
                                text: title,
                                highlight: highlight,
                              ),
                              Gap.h4,
                              AppText.body(
                                subtitle,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: VinkolPalette.white,
                                lineHeight: 1.3,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: _artWidth),
                      ],
                    ),
                  ),

                  PositionedDirectional(
                    end: -10,
                    bottom: -20,
                    child: ExcludeSemantics(
                      child: Transform.rotate(
                        angle: -8 * math.pi / 180,
                        child: const Text(
                          '🎁',
                          style: TextStyle(fontSize: 88, height: 1),
                        ),
                      ),
                    ),
                  ),

                  // // Badge over the illustration.
                  // PositionedDirectional(
                  //   end: 86,
                  //   bottom: 52,
                  //   child: ExcludeSemantics(
                  //     child: Transform.rotate(
                  //       angle: -12 * math.pi / 180,
                  //       child: Container(
                  //         width: 44,
                  //         height: 44,
                  //         alignment: Alignment.center,
                  //         decoration: const BoxDecoration(
                  //           shape: BoxShape.circle,
                  //           color: VinkolPalette.dangerFill,
                  //         ),
                  //         child: AppText.caption(
                  //           badge,
                  //           fontSize: 13,
                  //           fontWeight: FontWeight.w800,
                  //           color: VinkolPalette.white,
                  //           maxLines: 1,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The card title with the discount figure picked out in the brand blue.
/// Same type as the old `AppText.h3` title; only the highlight's color
/// differs. `brand300` is the brand step for text on a dark ground — `500`
/// is 1.5:1 on the promo violet.
class _HighlightedTitle extends StatelessWidget {
  const _HighlightedTitle({required this.text, required this.highlight});

  final String text;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    final style = headingStyle3.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: VinkolPalette.white,
      letterSpacing: -0.3,
    );
    final at = text.indexOf(highlight);
    if (at < 0) {
      return Text(text,
          style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, at)),
          TextSpan(
            text: highlight,
            style: const TextStyle(color: VinkolPalette.warningDark),
          ),
          TextSpan(text: text.substring(at + highlight.length)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
