import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_codes/core/design/design.dart';

/// A one-time-code input: N cells, one hidden field.
///
/// One [TextField] behind the cells rather than one per digit. Per-digit fields fight
/// autofill, break paste, and move focus in ways a screen reader cannot follow; a single
/// field with `oneTimeCode` autofill lets the platform drop the code straight in from an
/// email or SMS.
///
/// The active cell is ringed and the entered ones are bordered in the brand, so position is
/// carried by shape as well as colour.
class VinkolOtpField extends StatefulWidget {
  const VinkolOtpField({
    super.key,
    required this.controller,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.error,
    this.enabled = true,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final int length;

  /// Fires once the last digit lands. Verifying automatically is the point of a code field —
  /// nobody wants to type six digits and then hunt for a button.
  final ValueChanged<String>? onCompleted;

  final ValueChanged<String>? onChanged;

  /// Stated in words under the cells, never a red border alone.
  final String? error;

  final bool enabled;
  final bool autofocus;

  @override
  State<VinkolOtpField> createState() => _VinkolOtpFieldState();
}

class _VinkolOtpFieldState extends State<VinkolOtpField> {
  final FocusNode _focus = FocusNode();

  /// The last value seen. A [TextEditingController] notifies on selection changes as well as
  /// text changes, so without this `onCompleted` fires twice for one code — and two calls to
  /// `verify-email` means the second one fails with "code already used".
  String _last = '';

  @override
  void initState() {
    super.initState();
    _last = widget.controller.text;
    widget.controller.addListener(_onChanged);
    _focus.addListener(() => setState(() {}));
  }

  void _onChanged() {
    final text = widget.controller.text;
    if (text == _last) return;
    final wasComplete = _last.length == widget.length;
    _last = text;
    setState(() {});
    widget.onChanged?.call(text);
    if (text.length == widget.length && !wasComplete) {
      widget.onCompleted?.call(text);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final value = widget.controller.text;
    final hasError = widget.error != null && widget.error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: <Widget>[
            // The real field, invisible but focusable and autofillable.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.number,
                  autofillHints: const <String>[AutofillHints.oneTimeCode],
                  maxLength: widget.length,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  showCursor: false,
                  decoration: const InputDecoration(counterText: ''),
                ),
              ),
            ),
            Semantics(
              label: '${value.length} of ${widget.length} digits entered',
              liveRegion: true,
              child: GestureDetector(
                onTap: widget.enabled ? () => _focus.requestFocus() : null,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: <Widget>[
                    for (var i = 0; i < widget.length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: _Cell(
                          digit: i < value.length ? value[i] : null,
                          active: _focus.hasFocus && i == value.length,
                          error: hasError,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: VinkolSpace.md),
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
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.digit, required this.active, required this.error});

  final String? digit;
  final bool active;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final filled = digit != null;

    final Color edge;
    if (error) {
      edge = v.danger;
    } else if (active || filled) {
      edge = v.brand;
    } else {
      edge = v.borderSubtle;
    }

    return AnimatedContainer(
      duration: VinkolMotion.respecting(context, VinkolMotion.fast),
      curve: VinkolMotion.standard,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brSm,
        border: Border.fromBorderSide(
          BorderSide(color: edge, width: active || error ? 2 : 1),
        ),
        // The focus ring: zero blur, a token colour, drawn outside the box so the cells do
        // not shift as focus moves.
        boxShadow: active
            ? <BoxShadow>[BoxShadow(color: v.brandHalo, spreadRadius: 3)]
            : const <BoxShadow>[],
      ),
      child: Text(
        digit ?? '',
        style: VinkolType.numL.copyWith(color: v.textPrimary),
      ),
    );
  }
}
