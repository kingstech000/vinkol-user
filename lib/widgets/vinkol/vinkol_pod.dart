import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// One of the pod's five destinations.
class VinkolPodTab {
  const VinkolPodTab({
    required this.icon,
    required this.label,
    this.enabled = true,
  });

  final IconData icon;

  /// Shown when this tab is the active one, and always available to a screen reader.
  final String label;

  /// A disabled tab still occupies its slot — the pod's five positions are muscle memory,
  /// so nothing is ever removed from it.
  final bool enabled;
}

/// **The Pod** — design signature #2.
///
/// Five tabs in a floating pill. The active tab expands into a pill *inside* the pill and
/// reveals its label, so the selected state carries shape and width as well as colour and
/// survives greyscale (decision D-08).
///
/// It stays dark in light mode. That is deliberate: the pod is the one constant object
/// across both themes and the strongest piece of Vinkol's existing identity
/// (`02-do-not-lose.md` #2), which is why it reads `podSurface` rather than `surface`.
///
/// There is never a second bottom bar. When a delivery is live this same object carries the
/// status; it does not gain a sibling.
class VinkolPod extends StatelessWidget {
  const VinkolPod({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<VinkolPodTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  /// Clearance a scrolling body needs so its last row is never trapped under the pod:
  /// 60pt of pod, the 20pt it floats above the edge, and 24pt of breathing room. It does
  /// **not** include the home-indicator inset — use [bodyInsetOf] for that.
  static const double bodyInset = 104;

  /// [bodyInset] for this device. Adds whatever bottom inset the body still owes — the home
  /// indicator on a modern phone, zero inside a [SafeArea], which has already paid it.
  static double bodyInsetOf(BuildContext context) =>
      bodyInset + MediaQuery.paddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    // Guarded in build, not the initialiser list, so the constructor stays const. Five is
    // not a default — the pod's positions are muscle memory (D-08).
    assert(tabs.length == 5, 'The pod has exactly five destinations (D-08).');
    final v = context.vinkol;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: VinkolSpace.lg,
        end: VinkolSpace.lg,
        bottom: VinkolSpace.xl + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: v.podSurface,
          borderRadius: VinkolRadius.brFull,
          border: Border.fromBorderSide(BorderSide(color: v.podBorder)),
          boxShadow: VinkolElevation.e2(v),
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Row(
            children: <Widget>[
              for (var i = 0; i < tabs.length; i++)
                // 19:10 rather than 1.9:1 — Flutter's flex is an integer, and the active
                // tab is 1.9× a resting one in the prototype.
                Expanded(
                  flex: i == currentIndex ? 19 : 10,
                  child: _PodTab(
                    tab: tabs[i],
                    active: i == currentIndex,
                    onTap: tabs[i].enabled ? () => onSelected(i) : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodTab extends StatefulWidget {
  const _PodTab({required this.tab, required this.active, this.onTap});

  final VinkolPodTab tab;
  final bool active;
  final VoidCallback? onTap;

  @override
  State<_PodTab> createState() => _PodTabState();
}

class _PodTabState extends State<_PodTab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final disabled = widget.onTap == null;

    final Color fill;
    final Color ink;
    if (widget.active) {
      fill = v.brand;
      ink = v.onBrand;
    } else {
      // Pressed is a lift in surface, not a shadow — the pod is already the lifted object.
      fill = _pressed ? v.surfaceAlt : Colors.transparent;
      ink = disabled ? v.borderStrong : v.podText;
    }

    return Semantics(
      button: true,
      selected: widget.active,
      enabled: !disabled,
      label: widget.tab.label,
      // One node per tab, labelled once. Without this the active tab's visible label merges
      // with the semantic label and a screen reader reads the name twice.
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: VinkolMotion.respecting(context, VinkolMotion.base),
          curve: VinkolMotion.emphasized,
          // 46 + the 7pt of pod padding above and below clears the 44pt minimum target.
          constraints: const BoxConstraints(minHeight: 46),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: VinkolRadius.brFull,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(widget.tab.icon, size: 21, color: ink),
              if (widget.active)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: VinkolSpace.sm,
                      end: VinkolSpace.xs,
                    ),
                    // The label is why the active tab is wider. It has to be allowed to
                    // ellipsise: "Records" is "Registres" in French and longer again in
                    // German.
                    child: Text(
                      widget.tab.label,
                      style: VinkolType.label.copyWith(color: ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
