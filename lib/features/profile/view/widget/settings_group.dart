import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/gap.dart';

/// The settings vocabulary shared by every profile screen.
///
/// One surface treatment, decided once: a white card with a hairline border on
/// the app's off-white canvas, rows separated by an inset hairline rather than
/// by a gap. Cards do not repeat per row — a group is one object — which is
/// what gives the profile area its density and keeps five destinations from
/// reading as five identical banners.

/// Height of the leading icon column, so dividers can be inset to align with
/// the text rather than cutting the icon off.
const double _kRowIndent = 52;

/// What the end of a row promises.
enum RowAffordance {
  /// Pushes another screen inside the app.
  chevron,

  /// Leaves the app — a browser, the dialler, the mail client.
  external,

  /// Nothing is promised: either the row is information, or it acts in place —
  /// logging out, checking for an update — rather than going anywhere. An
  /// imperative title is what marks the second case.
  none,
}

/// A small-caps section label. Groups the list into named decisions instead of
/// one undifferentiated stack.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: AppText.button(
        text.toUpperCase(),
        color: AppColors.greyLight,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// A titled card holding a run of rows.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.children,
    this.label,
    this.footnote,
    this.indent = _kRowIndent,
  });

  final List<Widget> children;

  /// Rendered above the card as a small-caps label.
  final String? label;

  /// Rendered below the card. For the sentence that stops a row needing a
  /// subtitle of its own.
  final String? footnote;

  /// Where the dividers start. Drop to 16 for a group whose rows carry no icon.
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) SectionLabel(label!),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            // border: Border.all(color: AppColors.lightgrey),
          ),
          child: Column(children: _withDividers()),
        ),
        // if (footnote != null) ...[
        //   Gap.h8,
        //   AppText.caption(
        //     footnote!,
        //     color: AppColors.darkgrey,
        //     fontSize: 12,
        //     lineHeight: 1.45,
        //   ),
        // ],
      ],
    );
  }

  List<Widget> _withDividers() {
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        out.add(
          Padding(
            padding: EdgeInsetsDirectional.only(start: indent),
            child: const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.lightgrey,
            ),
          ),
        );
      }
      out.add(children[i]);
    }
    return out;
  }
}

/// One row of a [SettingsGroup].
///
/// [value] is the current setting, read right-aligned; [subtitle] is the
/// explanation, read under the title. A row uses one or the other, never both,
/// so the eye has a single place to look for the answer.
///
/// [value] and the title share the row evenly, so a value longer than about
/// half the row ellipsizes. Anything that long — an email address, a full
/// street address — belongs in [subtitle], which gets the whole width.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    this.icon,
    this.value,
    this.subtitle,
    this.onTap,
    this.affordance = RowAffordance.chevron,
    this.destructive = false,
  });

  final String title;
  final IconData? icon;
  final String? value;
  final String? subtitle;
  final VoidCallback? onTap;
  final RowAffordance affordance;

  /// Logging out, deleting an account. Carried by the icon and the label
  /// together, in [AppColors.redText] rather than [AppColors.red] — the accent
  /// red is only 4.05:1 on white and cannot be read at 15px.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: destructive ? AppColors.redText : AppColors.darkgrey,
            ),
            Gap.w16,
          ],
          // Title and value share one Expanded and split the slack between
          // themselves. Two sibling flex children would not: Expanded is tight
          // and fills its half, the value shrink-wraps its half, and the
          // difference collects after the last child — which walks the chevron
          // in from the edge and breaks its alignment with the rows above.
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.body(
                        title,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color:
                            destructive ? AppColors.redText : AppColors.black,
                        maxLines: 1,
                      ),
                      if (subtitle != null) ...[
                        Gap.h2,
                        AppText.caption(
                          subtitle!,
                          fontSize: 12,
                          color: AppColors.darkgrey,
                          maxLines: 2,
                        ),
                      ],
                    ],
                  ),
                ),
                if (value != null)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 12),
                      child: AppText.body(
                        value!,
                        fontSize: 14,
                        color: AppColors.darkgrey,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (affordance != RowAffordance.none) ...[
            Gap.w8,
            Icon(
              affordance == RowAffordance.external
                  ? PhosphorIconsRegular.arrowUpRight
                  : PhosphorIconsRegular.caretRight,
              size: 16,
              color: AppColors.darkgrey,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

/// A row whose control is a switch. The whole row is the target, not just the
/// switch, so the tap area matches what the row looks like.
class SettingsToggle extends StatelessWidget {
  const SettingsToggle({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.icon,
    this.subtitle,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: AppColors.darkgrey),
                Gap.w16,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.body(
                      title,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                      maxLines: 2,
                    ),
                    if (subtitle != null) ...[
                      Gap.h2,
                      AppText.caption(
                        subtitle!,
                        fontSize: 12,
                        color: AppColors.darkgrey,
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
              Gap.w12,
              Transform.scale(
                scale: 0.8,
                child: CupertinoSwitch(
                  value: value,
                  onChanged: onChanged,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.lightgrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
