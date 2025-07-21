// lib/screens/home/widgets/ride_details_input.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/features/booking/view/screen/location_search_screen.dart';
import 'package:starter_codes/features/booking/view/screen/map_picker_screen.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

class RideDetailsInput extends ConsumerWidget {
  const RideDetailsInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideLocationState = ref.watch(rideLocationProvider);
    final rideLocationNotifier = ref.read(rideLocationProvider.notifier);

    Future<void> showLocationSelectionOptions(bool isPickup) async {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.search, color: AppColors.primary),
                  title: const Text('Search for location',
                      style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.pop(context); // Close bottom sheet
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LocationSearchScreen(isPickupLocation: isPickup),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.map, color: AppColors.primary),
                  title: const Text('Pick from map',
                      style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.pop(context); // Close bottom sheet
                    final LocationModel? pickedLocation = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapPickerScreen(),
                      ),
                    );
                    if (pickedLocation != null) {
                      if (isPickup) {
                        rideLocationNotifier.setPickUpLocation(pickedLocation);
                      } else {
                        rideLocationNotifier.setDropOffLocation(pickedLocation);
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => showLocationSelectionOptions(true),
            child: _buildLocationInputRow(
              hintText: rideLocationState.pickUpLocation?.formattedAddress ??
                  'Add your pick-up location',
              icon: Icons.location_on_outlined,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: 1.5708,
                  child: IconButton(
                    icon: const Icon(Icons.swap_vert, color: AppColors.primary),
                    onPressed: () {
                      rideLocationNotifier.swapLocations();
                    },
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showLocationSelectionOptions(false),
            child: _buildLocationInputRow(
              hintText: rideLocationState.dropOffLocation?.formattedAddress ??
                  'Add your drop-off location',
              icon: Icons.location_on_outlined,
            ),
          ),
          Gap.h12,
          SizedBox(
            width: 200,
            child: AppButton(
              title: 'Find Rider',
              onTap: () {
                final currentPickUp = rideLocationState.pickUpLocation;
                final currentDropOff = rideLocationState.dropOffLocation;

                if (currentPickUp != null && currentDropOff != null) {
                  print(
                      'Pick-up Location: ${currentPickUp.formattedAddress}, Coordinates: ${currentPickUp.coordinates}');
                  print(
                      'Drop-off Location: ${currentDropOff.formattedAddress}, Coordinates: ${currentDropOff.coordinates}');
                  NavigationService.instance
                      .navigateTo(NavigatorRoutes.packageInfoScreen);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please select both pick-up and drop-off locations.')),
                  );
                }
              },
              color: AppColors.white,
            ),
          ),
          Gap.h12,
        ],
      ),
    );
  }

  Widget _buildLocationInputRow(
      {required String hintText, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          Gap.w10,
          Expanded(
            child: Text(
              hintText,
              style: TextStyle(color: Colors.grey[400]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
