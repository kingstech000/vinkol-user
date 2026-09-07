import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

import 'vinkol_form_scaffold.dart';

/// A section heading: the label on the start edge, an optional running figure on the end.
///
/// The figure is the point — a section called "Drop-offs" or "Items" that does not say how
/// many makes the user count. Every list section in the product carries its own total.
class VinkolSectionHeader extends StatelessWidget {
  const VinkolSectionHeader({
    super.key,
    required this.label,
    this.meta,
    this.action,
  });

  final String label;

  /// A count, a distance, a qualifier — "3", "18.4 km", "Priced separately".
  final String? meta;

  /// A trailing affordance: "Change", "See all". Takes the place of [meta].
  final ({String label, VoidCallback onTap})? action;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Padding(
      padding: const EdgeInsets.only(
        top: VinkolSpace.xxl,
        bottom: VinkolSpace.md,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: VinkolType.h4.copyWith(color: v.textPrimary),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: action!.onTap,
              behavior: HitTestBehavior.opaque,
              child: Semantics(
                button: true,
                child: Text(
                  action!.label,
                  style: VinkolType.label.copyWith(color: v.textBrand),
                ),
              ),
            )
          else if (meta != null)
            Text(
              meta!,
              style: VinkolType.num.copyWith(color: v.textTertiary),
            ),
        ],
      ),
    );
  }
}

/// How loud a [VinkolNotice] is.
enum VinkolNoticeTone { info, warning }

/// A short standing statement about the screen: a rule, or what the current input adds up to.
///
/// Not an alert and not a toast — it does not interrupt and it does not go away, because what
/// it says is true for as long as the screen is open. "One store per order" and "1 pickup ·
/// 3 drop-offs" are the same kind of fact.
class VinkolNotice extends StatelessWidget {
  const VinkolNotice({
    super.key,
    required this.headline,
    required this.body,
    this.icon = Icons.info_outline,
    this.tone = VinkolNoticeTone.info,
  });

  final String headline;
  final String body;
  final IconData icon;

  /// Info by default. [VinkolNoticeTone.warning] is for a standing consequence the user is
  /// about to accept — "withdrawals are final" — not for an error, which is a state view.
  final VinkolNoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final bool warn = tone == VinkolNoticeTone.warning;
    final Color accent = warn ? v.warning : v.info;

    return Container(
      padding: const EdgeInsets.all(VinkolSpace.md),
      decoration: BoxDecoration(
        color: warn ? v.warningGround : v.infoGround,
        borderRadius: VinkolRadius.brSm,
        border: Border.fromBorderSide(BorderSide(color: v.borderSubtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: VinkolSpace.iconToLabel),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  headline,
                  style: VinkolType.label
                      .copyWith(color: warn ? accent : v.textPrimary),
                ),
                const SizedBox(height: VinkolSpace.xxs),
                Text(
                  body,
                  style: VinkolType.bodyS.copyWith(color: v.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The bottom action bar: what has been built, what it costs, and the way forward.
///
/// Anchored rather than scrolled, so a tenth stop or a twentieth cart item never pushes the
/// action off screen. The value sits in tabular figures on the end axis (signature #4) — it
/// is the number the user is deciding about.
class VinkolDock extends StatelessWidget {
  const VinkolDock({
    super.key,
    required this.label,
    required this.actionLabel,
    required this.onAction,
    this.value,
    this.detail,
    this.loading = false,
  });

  /// "3 items in cart", "2 drop-offs", "Total".
  final String label;

  /// The money, already formatted through the market layer.
  final String? value;

  /// The blocking condition, when there is one: "2 stops still need details".
  final String? detail;

  final String actionLabel;

  /// Null disables the action. The dock still says why in [detail] — a disabled button with
  /// no stated reason is a dead end.
  final VoidCallback? onAction;

  final bool loading;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Container(
      padding: EdgeInsets.fromLTRB(
        VinkolSpace.pageMargin,
        VinkolSpace.lg,
        VinkolSpace.pageMargin,
        VinkolSpace.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: v.surface,
        border: Border(top: BorderSide(color: v.borderSubtle)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: VinkolType.num.copyWith(color: v.textSecondary),
                ),
              ),
              if (value != null) ...<Widget>[
                const SizedBox(width: VinkolSpace.md),
                Text(
                  value!,
                  style: VinkolType.numL.copyWith(color: v.textPrimary),
                ),
              ],
            ],
          ),
          if (detail != null) ...<Widget>[
            const SizedBox(height: VinkolSpace.xxs),
            Text(
              detail!,
              style: VinkolType.bodyS.copyWith(color: v.textTertiary),
            ),
          ],
          const SizedBox(height: VinkolSpace.md),
          VinkolPrimaryButton(
            label: actionLabel,
            loading: loading,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

/// The two-way tab control at the top of a records-style list.
///
/// A pill track rather than the saturated segmented control: both screens that use it —
/// Records and Wallet — already spend their one saturated object on something else, and a
/// second one would break D-07. The indicator is a plain surface pill; contrast comes from
/// the track behind it.
class VinkolTabBar extends StatelessWidget {
  const VinkolTabBar(
      {super.key, required this.controller, required this.labels});

  final TabController controller;

  /// Two to four already-localized labels.
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    // Scales with the user's text setting rather than clipping at 2.0x (D-04).
    final double tabHeight =
        MediaQuery.textScalerOf(context).scale(VinkolType.label.fontSize!) + 22;

    return Container(
      padding: const EdgeInsets.all(VinkolSpace.xs),
      decoration: BoxDecoration(
        color: v.surfaceAlt,
        borderRadius: VinkolRadius.brFull,
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: v.surface,
          borderRadius: VinkolRadius.brFull,
        ),
        labelColor: v.textPrimary,
        unselectedLabelColor: v.textSecondary,
        labelStyle: VinkolType.label,
        unselectedLabelStyle: VinkolType.label,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        tabs: <Widget>[
          for (final String label in labels)
            Tab(height: tabHeight, text: label),
        ],
      ),
    );
  }
}
