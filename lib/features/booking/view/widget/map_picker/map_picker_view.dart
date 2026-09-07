import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/state_boundaries.dart';
import 'package:starter_codes/features/booking/view/widget/map_picker/map_zoom_controls.dart';
import 'package:starter_codes/features/booking/view/widget/map_picker/picked_location_card.dart';
import 'package:starter_codes/l10n/l10n.dart';

/// The location picker's chrome: the map, the fixed centre crosshair, the zoom
/// controls and the address card. All state lives in the host screen.
class MapPickerView extends StatelessWidget {
  final String? userState;
  final StateBoundary? stateBoundary;
  final CameraPosition initialCameraPosition;
  final String? pickedAddress;
  final bool isLoadingAddress;
  final bool showingStateError;

  final void Function(GoogleMapController) onMapCreated;
  final void Function(CameraPosition) onCameraMove;
  final VoidCallback onCameraIdle;
  final VoidCallback onCurrentLocation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onConfirm;

  const MapPickerView({
    super.key,
    required this.userState,
    required this.stateBoundary,
    required this.initialCameraPosition,
    required this.pickedAddress,
    required this.isLoadingAddress,
    required this.showingStateError,
    required this.onMapCreated,
    required this.onCameraMove,
    required this.onCameraIdle,
    required this.onCurrentLocation,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pick Location${userState != null ? ' in $userState' : ''}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // Current location button in app bar
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.primary),
            onPressed: onCurrentLocation,
            tooltip: context.l10n.bookingGoToCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            onMapCreated: onMapCreated,
            onCameraMove: onCameraMove,
            onCameraIdle: onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // We'll use our custom button
            zoomControlsEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: false, // Disable tilt for better experience
            zoomGesturesEnabled: true,

            // Strict camera bounds to prevent moving outside state
            cameraTargetBounds: stateBoundary != null
                ? CameraTargetBounds(stateBoundary!.bounds)
                : CameraTargetBounds.unbounded,

            // Restrict zoom range to prevent getting too far out
            minMaxZoomPreference: stateBoundary != null
                ? const MinMaxZoomPreference(14.0,
                    20.0) // Street-level min zoom for better street visibility
                : const MinMaxZoomPreference(14.0, 20.0),

            mapType: MapType.normal,
            buildingsEnabled: true,
            trafficEnabled: false,
          ),

          // Center crosshair
          const Center(
            child: Icon(
              CupertinoIcons.map_pin,
              color: AppColors.primary,
              size: 40,
            ),
          ),

          // Zoom controls
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: 16,
            child: MapZoomControls(onZoomIn: onZoomIn, onZoomOut: onZoomOut),
          ),

          // Bottom address card and confirm button
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: PickedLocationCard(
              address: pickedAddress,
              isLoadingAddress: isLoadingAddress,
              showingStateError: showingStateError,
              onConfirm: onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}
