import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';

/// A draggable sheet over a map that never opens taller than its content.
///
/// The content is laid out at its natural height and measured after each
/// frame; that height, plus the drag handle, caps the sheet's fully-open size
/// — so a short sheet stops under its last row instead of opening onto empty
/// white. Tall content still reaches [openSize] and scrolls. The resting and
/// collapsed sizes are clamped to the cap as well.
class ContentSizedSheet extends StatefulWidget {
  const ContentSizedSheet({
    super.key,
    required this.child,
    this.restingSize = 0.55,
    this.collapsedSize = 0.35,
    this.openSize = 0.95,
    this.color = VinkolPalette.white,
    this.onExtentChanged,
  });

  /// The sheet's content. Must not be its own scrollable — the sheet supplies
  /// the scroll view so the drag gesture and the scroll share one controller.
  final Widget child;

  /// Where the sheet sits when it opens, as a fraction of the available
  /// height, when the content is tall enough to need it.
  final double restingSize;

  /// How far it can be pulled down.
  final double collapsedSize;

  /// The most it can ever open, however tall the content.
  final double openSize;

  /// The sheet's ground. White by default; a sheet made of white cards sits
  /// on the canvas colour instead.
  final Color color;

  /// The sheet's current extent as a fraction, on every drag frame — for a
  /// parent that hides map chrome once the sheet covers it.
  final ValueChanged<double>? onExtentChanged;

  @override
  State<ContentSizedSheet> createState() => _ContentSizedSheetState();
}

class _ContentSizedSheetState extends State<ContentSizedSheet> {
  double? _contentHeight;

  void _onContentHeight(double height) {
    if (!mounted || _contentHeight == height) return;
    setState(() => _contentHeight = height);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (n) {
        widget.onExtentChanged?.call(n.extent);
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = _contentHeight;
          var maxSize = widget.openSize;
          if (content != null && constraints.maxHeight > 0) {
            final fits = (content + _DragHandle.height) / constraints.maxHeight;
            maxSize = fits.clamp(0.0, widget.openSize);
          }
          final initialSize = math.min(widget.restingSize, maxSize);
          final minSize = math.min(widget.collapsedSize, maxSize);

          return DraggableScrollableSheet(
            initialChildSize: initialSize,
            minChildSize: minSize,
            maxChildSize: maxSize,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                  border: Border.all(color: VinkolPalette.neutral200),
                ),
                child: Column(
                  children: [
                    const _DragHandle(),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: _MeasureSize(
                          onChange: (size) => _onContentHeight(size.height),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  static const _bar = 4.0;

  /// The vertical space the handle takes, added to the content height.
  static double get height => 20.h + _bar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Container(
        width: 36.w,
        height: _bar,
        decoration: BoxDecoration(
          color: VinkolPalette.neutral300,
          borderRadius: BorderRadius.circular(999.r),
        ),
      ),
    );
  }
}

/// Reports the laid-out size of its child.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, required super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(
      BuildContext context, _RenderMeasureSize renderObject) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _reported;

  @override
  void performLayout() {
    super.performLayout();
    if (_reported == size) return;
    _reported = size;
    final reported = size;
    // Layout is not the place to call setState; report once the frame is done.
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(reported));
  }
}
