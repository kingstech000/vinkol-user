import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// Collects the four-digit delivery PIN a recipient reads out, and resolves to it — or to
/// null if the sheet is dismissed.
///
/// Reworked to the token system. Three real fixes came with it:
///
/// - **The digits were invisible.** A filled cell painted the brand at 80% opacity and drew
///   a white bullet on it, so the number the user typed was never shown. It shows the digit
///   now, which is what lets someone catch a mistyped PIN.
/// - **The `radius` was horizontal**, giving a bottom sheet rounded left and right edges
///   rather than rounded top corners.
/// - **The keypad had no minimum target.** `childAspectRatio: 1.7` on a 3-column grid put
///   the keys under 44pt on a small phone.
Future<String?> showTransactionPinModal(BuildContext context) {
  final Completer<String?> pinCompleter = Completer<String?>();
  var enteredPin = '';
  FocusScope.of(context).unfocus();

  void resolve(String? value) {
    if (!pinCompleter.isCompleted) pinCompleter.complete(value);
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final v = context.vinkol;
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void append(String digit) {
              if (enteredPin.length >= 4) return;
              setState(() => enteredPin += digit);
              if (enteredPin.length == 4) {
                resolve(enteredPin);
                Navigator.of(context).pop();
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: v.surface,
                borderRadius: VinkolRadius.brSheet,
                border:
                    BorderDirectional(top: BorderSide(color: v.borderSubtle)),
              ),
              padding: const EdgeInsetsDirectional.fromSTEB(
                VinkolSpace.xl,
                VinkolSpace.md,
                VinkolSpace.xl,
                VinkolSpace.xl,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: v.borderStrong,
                              borderRadius: VinkolRadius.brFull,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Semantics(
                          button: true,
                          label: 'Cancel',
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              resolve(null);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(VinkolSpace.sm),
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: v.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: VinkolSpace.sm),
                    Text(
                      'Enter the delivery PIN',
                      style: VinkolType.h3.copyWith(color: v.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: VinkolSpace.xs),
                    Text(
                      'Ask the recipient for the four digits they were given. '
                      'Entering it marks this delivery as delivered.',
                      style: VinkolType.bodyS.copyWith(color: v.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: VinkolSpace.xl),
                    _PinCells(pin: enteredPin),
                    const SizedBox(height: VinkolSpace.xl),
                    _Keypad(
                      onDigit: append,
                      onBackspace: enteredPin.isEmpty
                          ? null
                          : () => setState(() => enteredPin =
                              enteredPin.substring(0, enteredPin.length - 1)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  ).then((_) => resolve(null));

  return pinCompleter.future;
}

/// Four cells. The active one is ringed, the filled ones show their digit.
class _PinCells extends StatelessWidget {
  const _PinCells({required this.pin});

  final String pin;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return Semantics(
      label: '${pin.length} of 4 digits entered',
      liveRegion: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var i = 0; i < 4; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: VinkolSpace.md),
            AnimatedContainer(
              duration: VinkolMotion.respecting(context, VinkolMotion.fast),
              curve: VinkolMotion.standard,
              width: 56,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: v.surface,
                borderRadius: VinkolRadius.brSm,
                border: Border.fromBorderSide(
                  BorderSide(
                    color: pin.length == i ? v.brand : v.borderSubtle,
                    width: pin.length == i ? 2 : 1,
                  ),
                ),
                // A focus ring, not a shadow: zero blur, a token ramp colour, drawn
                // outside the box so it does not shift layout. Flutter has no ring
                // primitive that does this.
                boxShadow: pin.length == i
                    ? <BoxShadow>[
                        BoxShadow(color: v.brandHalo, spreadRadius: 3)
                      ]
                    : const <BoxShadow>[],
              ),
              child: Text(
                pin.length > i ? pin[i] : '',
                style: VinkolType.numL.copyWith(color: v.textPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback? onBackspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var row = 0; row < 4; row++) ...<Widget>[
          if (row > 0) const SizedBox(height: VinkolSpace.md),
          Row(
            children: <Widget>[
              for (var col = 0; col < 3; col++) ...<Widget>[
                if (col > 0) const SizedBox(width: VinkolSpace.md),
                Expanded(child: _key(row, col)),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _key(int row, int col) {
    final index = row * 3 + col;
    if (index == 9) return const SizedBox(height: 56);
    if (index == 10) return _KeyButton(label: '0', onTap: () => onDigit('0'));
    if (index == 11) {
      return _KeyButton(
        icon: Icons.backspace_outlined,
        semanticLabel: 'Delete',
        onTap: onBackspace,
      );
    }
    final digit = '${index + 1}';
    return _KeyButton(label: digit, onTap: () => onDigit(digit));
  }
}

class _KeyButton extends StatefulWidget {
  const _KeyButton({
    this.label,
    this.icon,
    this.semanticLabel,
    this.onTap,
  });

  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final VoidCallback? onTap;

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final disabled = widget.onTap == null;

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.semanticLabel ?? widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: VinkolMotion.respecting(context, VinkolMotion.instant),
          curve: VinkolMotion.standard,
          // 56pt clears the 44pt minimum on every phone width.
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _pressed ? v.surfaceStrong : v.surfaceAlt,
            borderRadius: VinkolRadius.brSm,
          ),
          child: widget.icon != null
              ? Icon(
                  widget.icon,
                  size: 22,
                  color: disabled ? v.textTertiary : v.textSecondary,
                )
              : Text(
                  widget.label!,
                  style: VinkolType.numL.copyWith(color: v.textPrimary),
                ),
        ),
      ),
    );
  }
}
