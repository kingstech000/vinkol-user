import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CircularNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final String? placeholderAsset; // Optional: path to a local placeholder asset
  final BoxFit fit;

  const CircularNetworkImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.placeholderAsset, // Now optional
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // Default dimensions if not provided, scaled by ScreenUtil
    final double effectiveHeight = height ?? 40.h;
    final double effectiveWidth = width ?? 40.w;

    return ClipOval(
      child: Container(
        height: effectiveHeight,
        width: effectiveWidth,
        color: Colors.grey.shade200, // Default background for placeholder/error
        child: FadeInImage.assetNetwork(
          placeholder: placeholderAsset ??
              'assets/images/placeholder_user.png', // Fallback placeholder if none provided
          image: imageUrl,
          height: effectiveHeight,
          width: effectiveWidth,
          fit: fit,
          imageErrorBuilder: (context, error, stackTrace) {
            // Return a simple grey box on error
            return Container(
              height: effectiveHeight,
              width: effectiveWidth,
              color: Colors.grey, // Solid grey box for error
              child: const Icon(
                Icons.person, // Optional: add a person icon in the grey box
                color: Colors.white,
                size: 24, // Adjust size as needed
              ),
            );
          },
        ),
      ),
    );
  }
}
