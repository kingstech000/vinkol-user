
// Custom Dot Spinning Indicator
import 'package:flutter/material.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'dart:math' as math; // For math.pi


class DotSpinningIndicator extends StatefulWidget {
  const DotSpinningIndicator({
    super.key,
    this.color = AppColors.primary,
    this.size = 30.0,
    this.dotSize = 6.0,
    this.duration = const Duration(milliseconds: 1200),
  });

  final Color color;
  final double size;
  final double dotSize;
  final Duration duration;

  @override
  State<DotSpinningIndicator> createState() => _DotSpinningIndicatorState();
}

class _DotSpinningIndicatorState extends State<DotSpinningIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: Size.square(widget.size),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2.0 * math.pi,
              child: Stack(
                children: <Widget>[
                  // Main dot
                  Positioned(
                    left: (widget.size - widget.dotSize) / 2,
                    top: 0,
                    child: _buildDot(widget.color),
                  ),
                  // Fading trail dots
                  Positioned(
                    left: (widget.size - widget.dotSize) / 2,
                    top: widget.size * 0.2, // Adjust position
                    child: Opacity(
                      opacity: 1.0 - _controller.value * 2 > 0 ? 1.0 - _controller.value * 2 : 0,
                      child: _buildDot(widget.color.withOpacity(0.7)),
                    ),
                  ),
                  Positioned(
                    left: (widget.size - widget.dotSize) / 2,
                    top: widget.size * 0.4, // Adjust position
                    child: Opacity(
                      opacity: 1.0 - _controller.value * 1.5 > 0 ? 1.0 - _controller.value * 1.5 : 0,
                      child: _buildDot(widget.color.withOpacity(0.4)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: widget.dotSize,
      height: widget.dotSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}