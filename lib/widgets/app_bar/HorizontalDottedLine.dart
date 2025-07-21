import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HorizontalDottedLine extends StatelessWidget {
  final Color color;
  final double
      dotSize; // Renamed from dashWidth/dashHeight for clarity with dots
  final double dotSpace;
  final Axis direction;
  final double? totalLength;

  const HorizontalDottedLine({
    super.key,
    this.color = Colors.grey,
    this.dotSize = 1.0, // This will be both width and height for a circular dot
    this.dotSpace = 5.0,
    this.direction = Axis.horizontal,
    this.totalLength,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableLength = direction == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;

        final double effectiveLength = totalLength ?? availableLength;

        if (!effectiveLength.isFinite || effectiveLength <= 0) {
          return SizedBox(
            width: direction == Axis.horizontal
                ? 0.w
                : dotSize.w, // minimal thickness
            height: direction == Axis.vertical
                ? 0.h
                : dotSize.h, // minimal thickness
          );
        }

        // Calculate the number of dots
        final int numberOfDots =
            (effectiveLength / (dotSize + dotSpace)).floor();

        if (numberOfDots <= 0) {
          return SizedBox(
            width: direction == Axis.horizontal ? 0.w : dotSize.w,
            height: direction == Axis.vertical ? 0.h : dotSize.h,
          );
        }

        return Flex(
          direction: direction,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(numberOfDots, (_) {
            return SizedBox(
              width: dotSize
                  .w, // Use dotSize for both width and height to make it circular
              height: dotSize
                  .h, // Use dotSize for both width and height to make it circular
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
