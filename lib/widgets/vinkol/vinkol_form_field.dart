import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_codes/core/design/design.dart';

/// A form field: label above, input, then either a hint or an error **in words**.
///
/// The error is never a red border alone. It is a sentence, tied to this field, announced to
/// a screen reader, and accompanied by an icon — a red outline says something is wrong but
/// not what, and is invisible to a colourblind user (accessibility rule, `04-tokens.md` §8).
///
/// The label sits above the input rather than floating inside it: a floating label vanishes
/// once the field has content, which is exactly when a user scanning a long form needs it,
/// and it cannot survive a +40% translation without overlapping the value.
class VinkolFormField extends StatefulWidget {
  const VinkolFormField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.error,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.leading,
    this.trailing,
    this.onChanged,
    this.onTap,
    this.autofillHints,
    this.pill = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController? controller;

  /// Placeholder inside the field. Never a substitute for [label].
  final String? hint;

  /// Guidance shown when there is no [error] — a format, a rule.
  final String? helper;

  /// The failure, stated in words. Non-null puts the field in its error state.
  final String? error;

  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  /// An icon or the currency symbol. Keep it narrow — symbol widths vary by market.
  final Widget? leading;

  /// A visibility toggle, a unit, a clear button.
  final Widget? trailing;

  final ValueChanged<String>? onChanged;

  /// Makes the whole field a button — for a field whose value comes from a picker.
  final VoidCallback? onTap;

  final Iterable<String>? autofillHints;

  final TextCapitalization textCapitalization;

  /// The auth shape: a `full`-radius field under a quiet, sentence-cased label.
  ///
  /// The auth flow is the one place in the app where a screen is nothing but a form, so the
  /// field itself carries the weight the surrounding chrome carries elsewhere. Everywhere
  /// else — booking, personal info, add bank — the field sits among cards and rows, and a
  /// pill there would be the "pills for everything" failure the brief bans.
  final bool pill;

  @override
  State<VinkolFormField> createState() => _VinkolFormFieldState();
}

class _VinkolFormFieldState extends State<VinkolFormField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() => setState(() => _focused = _focus.hasFocus);

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final hasError = widget.error != null && widget.error!.isNotEmpty;

    final Color border;
    if (hasError) {
      border = v.danger;
    } else if (_focused) {
      border = v.brand;
    } else {
      border = v.borderSubtle;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          widget.label,
          style: (widget.pill ? VinkolType.body : VinkolType.label).copyWith(
            color: widget.enabled
                ? (widget.pill ? v.textTertiary : v.textSecondary)
                : v.textTertiary,
          ),
          // Two lines, because a label that fits in English may not in French.
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: VinkolSpace.sm),
        AnimatedContainer(
          duration: VinkolMotion.respecting(context, VinkolMotion.fast),
          curve: VinkolMotion.standard,
          constraints: const BoxConstraints(minHeight: 54),
          // A pill curves in at its ends, so its content needs to start further in or the
          // leading icon sits on the curve.
          padding: EdgeInsetsDirectional.symmetric(
              horizontal: widget.pill ? VinkolSpace.xl : 15),
          decoration: BoxDecoration(
            color: widget.enabled ? v.surface : v.surfaceAlt,
            borderRadius: widget.pill ? VinkolRadius.brFull : VinkolRadius.brSm,
            border: Border.fromBorderSide(
              BorderSide(color: border, width: _focused || hasError ? 2 : 1),
            ),
            // The focus halo. Opacity here is a state change, not a derived colour.
            boxShadow: _focused
                ? <BoxShadow>[BoxShadow(color: v.brandHalo, spreadRadius: 3)]
                : const <BoxShadow>[],
          ),
          child: Row(
            children: <Widget>[
              if (widget.leading != null) ...<Widget>[
                widget.leading!,
                const SizedBox(width: 11),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly || widget.onTap != null,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
                  maxLines: widget.maxLines,
                  onChanged: widget.onChanged,
                  onTap: widget.onTap,
                  autofillHints: widget.autofillHints,
                  textCapitalization: widget.textCapitalization,
                  style: VinkolType.body.copyWith(
                    color: widget.enabled ? v.textPrimary : v.textTertiary,
                  ),
                  cursorColor: v.brand,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: widget.hint,
                    hintStyle: VinkolType.body.copyWith(color: v.textTertiary),
                    // The container above draws the border; the field must not draw another.
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (widget.trailing != null) ...<Widget>[
                const SizedBox(width: 11),
                widget.trailing!,
              ],
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: VinkolSpace.sm),
            child: Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.error_outline, size: 15, color: v.danger),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      widget.error!,
                      style: VinkolType.bodyS.copyWith(color: v.danger),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (widget.helper != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: VinkolSpace.sm),
            child: Text(
              widget.helper!,
              style: VinkolType.bodyS.copyWith(color: v.textTertiary),
            ),
          ),
      ],
    );
  }
}

/// One option in a [VinkolSegmentedControl].
class VinkolSegment {
  const VinkolSegment({
    required this.label,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final IconData? icon;
  final bool enabled;
}

/// A segmented control — two to four mutually exclusive options, all visible at once.
///
/// The selected segment fills with the brand. It is the only saturated thing in a form, so a
/// screen with a hero card should prefer a different control: one saturated object per
/// screen (D-07).
class VinkolSegmentedControl extends StatelessWidget {
  const VinkolSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onSelected,
    this.enabled = true,
  });

  final List<VinkolSegment> segments;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // Guarded in build, not the initialiser list, so the constructor stays const.
    assert(segments.length >= 2 && segments.length <= 4,
        'Two to four segments. More than four is a chip row or a picker.');
    return Row(
      children: <Widget>[
        for (var i = 0; i < segments.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 9),
          Expanded(
            child: _Segment(
              segment: segments[i],
              selected: i == selectedIndex,
              onTap:
                  enabled && segments[i].enabled ? () => onSelected(i) : null,
            ),
          ),
        ],
      ],
    );
  }
}

class _Segment extends StatefulWidget {
  const _Segment({required this.segment, required this.selected, this.onTap});

  final VinkolSegment segment;
  final bool selected;
  final VoidCallback? onTap;

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final disabled = widget.onTap == null;

    final Color fill;
    final Color ink;
    final Color edge;
    if (widget.selected) {
      fill = disabled ? v.surfaceStrong : v.brand;
      ink = disabled ? v.textTertiary : v.onBrand;
      edge = disabled ? v.borderSubtle : v.brand;
    } else {
      fill = _pressed ? v.surfaceAlt : v.surface;
      ink = disabled ? v.textTertiary : v.textSecondary;
      edge = v.borderSubtle;
    }

    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: !disabled,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: VinkolMotion.respecting(context, VinkolMotion.fast),
          curve: VinkolMotion.standard,
          // 44pt minimum target even though the prototype's padding lands at 43.
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: VinkolSpace.sm,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: VinkolRadius.brSm,
            border: Border.fromBorderSide(BorderSide(color: edge)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.segment.icon != null) ...<Widget>[
                Icon(widget.segment.icon, size: 18, color: ink),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  widget.segment.label,
                  style: VinkolType.label.copyWith(color: ink),
                  textAlign: TextAlign.center,
                  // Two lines: the brief requires every button to wrap rather than clip.
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A binary toggle: the prototype's `.sw`.
///
/// The track carries the state as fill *and* as knob position, so it survives greyscale — a
/// switch that only changes colour is the same defect as a status that only changes colour
/// (D-05). The control is 46×27 to match the prototype, sat inside a 44pt-high target so a
/// thumb has something to hit.
///
/// [label] is required because an icon-free control needs an accessible name; it is read by
/// a screen reader and never drawn — the visible label belongs to the row that owns this.
class VinkolSwitch extends StatelessWidget {
  const VinkolSwitch({
    super.key,
    required this.value,
    required this.label,
    this.onChanged,
  });

  final bool value;

  /// The accessible name of what is being toggled.
  final String label;

  /// Null disables the switch. The owning row must still say why.
  final ValueChanged<bool>? onChanged;

  static const double _trackWidth = 46;
  static const double _trackHeight = 27;
  static const double _knob = 21;
  static const double _inset = 3;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final disabled = onChanged == null;
    final duration = VinkolMotion.respecting(context, VinkolMotion.fast);

    final Color track;
    if (disabled) {
      track = v.surfaceAlt;
    } else {
      track = value ? v.brand : v.surfaceStrong;
    }

    return Semantics(
      toggled: value,
      enabled: !disabled,
      label: label,
      child: GestureDetector(
        onTap: disabled ? null : () => onChanged!(!value),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 44,
          width: _trackWidth,
          child: Center(
            child: AnimatedContainer(
              duration: duration,
              curve: VinkolMotion.standard,
              width: _trackWidth,
              height: _trackHeight,
              decoration: BoxDecoration(
                color: track,
                borderRadius: VinkolRadius.brFull,
                border: Border.fromBorderSide(
                  BorderSide(
                      color: value && !disabled ? v.brand : v.borderSubtle),
                ),
              ),
              child: AnimatedAlign(
                duration: duration,
                curve: VinkolMotion.standard,
                alignment: value
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.symmetric(horizontal: _inset),
                  child: Container(
                    width: _knob,
                    height: _knob,
                    decoration: BoxDecoration(
                      color: disabled
                          ? v.textTertiary
                          : (value ? v.onBrand : v.textSecondary),
                      shape: BoxShape.circle,
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

/// A checkbox: a square that fills with the brand and gains a tick.
///
/// The tick matters. A box that only changes colour when checked is the same defect as a
/// status that only changes colour (D-05) — it disappears in greyscale and for a
/// colourblind user. Square rather than round, and [VinkolRadius.xs] rather than a pill,
/// because a checkbox that looks like a radio button tells the user they may pick only one.
///
/// Use [VinkolSwitch] for a setting that takes effect immediately, and this for a term the
/// user is agreeing to as part of submitting a form.
class VinkolCheckbox extends StatelessWidget {
  const VinkolCheckbox({
    super.key,
    required this.value,
    required this.label,
    this.onChanged,
    this.error = false,
  });

  final bool value;

  /// The accessible name of what is being agreed to. Read by a screen reader, never drawn —
  /// the visible label belongs to the row that owns this.
  final String label;

  final ValueChanged<bool>? onChanged;

  /// Draws the box in the danger colour. The row must still state the failure in words.
  final bool error;

  static const double _box = 21;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final disabled = onChanged == null;

    final Color edge;
    if (disabled) {
      edge = v.borderSubtle;
    } else if (value) {
      edge = v.brand;
    } else if (error) {
      edge = v.danger;
    } else {
      edge = v.borderStrong;
    }

    return Semantics(
      checked: value,
      enabled: !disabled,
      label: label,
      child: GestureDetector(
        onTap: disabled ? null : () => onChanged!(!value),
        behavior: HitTestBehavior.opaque,
        // The box is 21pt; the target around it is 44.
        child: SizedBox(
          height: 44,
          width: 44,
          child: Center(
            child: AnimatedContainer(
              duration: VinkolMotion.respecting(context, VinkolMotion.fast),
              curve: VinkolMotion.standard,
              width: _box,
              height: _box,
              decoration: BoxDecoration(
                color: value && !disabled ? v.brand : Colors.transparent,
                borderRadius: VinkolRadius.brXs,
                border:
                    Border.fromBorderSide(BorderSide(color: edge, width: 1.5)),
              ),
              child: value
                  ? Icon(Icons.check,
                      size: 15, color: disabled ? v.textTertiary : v.onBrand)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// A [VinkolCheckbox] with its visible label and, when it fails, the reason in words.
///
/// The whole row is the target, not just the box — a checkbox whose label is not tappable is
/// a 44pt-minimum failure dressed up as a design. [trailing] takes the end of the row, which
/// is where Login puts "Forgot password?".
class VinkolCheckboxRow extends StatelessWidget {
  const VinkolCheckboxRow({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.error,
    this.trailing,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  /// The failure, stated in words under the row.
  final String? error;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final hasError = error != null && error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Semantics(
                checked: value,
                label: label,
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => onChanged(!value),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      VinkolCheckbox(
                        value: value,
                        label: label,
                        error: hasError,
                        onChanged: onChanged,
                      ),
                      Flexible(
                        child: Text(
                          label,
                          style:
                              VinkolType.bodyS.copyWith(color: v.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: VinkolSpace.sm),
              trailing!,
            ],
          ],
        ),
        if (hasError)
          Padding(
            // Lines up with the label rather than the 44pt target's edge.
            padding: const EdgeInsetsDirectional.only(
                start: VinkolSpace.xs, top: VinkolSpace.xs),
            child: Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.error_outline, size: 15, color: v.danger),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      error!,
                      style: VinkolType.bodyS.copyWith(color: v.danger),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
