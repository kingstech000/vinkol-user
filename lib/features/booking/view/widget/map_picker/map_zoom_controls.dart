import 'package:flutter/material.dart';

/// The stacked zoom in / zoom out buttons floating over the picker map.
class MapZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const MapZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton.small(
          heroTag: "zoom_in",
          onPressed: onZoomIn,
          backgroundColor: Colors.white,
          child: const Icon(Icons.zoom_in, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: "zoom_out",
          onPressed: onZoomOut,
          backgroundColor: Colors.white,
          child: const Icon(Icons.zoom_out, color: Colors.black87),
        ),
      ],
    );
  }
}
