// lib/screens/location_search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/provider/location_provider.dart';
import 'package:starter_codes/widgets/app_bar/empty_app_bar.dart';

class LocationSearchScreen extends ConsumerStatefulWidget {
  final bool isPickupLocation;

  const LocationSearchScreen({super.key, required this.isPickupLocation});

  @override
  ConsumerState<LocationSearchScreen> createState() =>
      _LocationSearchScreenState();
}

class _LocationSearchScreenState extends ConsumerState<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final input = _searchController.text;
    if (input.isEmpty) {
      setState(() {
        _predictions = [];
        _isLoading = false; // Ensure loading is off if input is empty
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final locationController = ref.read(locationControllerProvider);
      final results =
          await locationController.searchPlaces(input, );

      setState(() {
        _predictions = results;
      });
    } catch (e) {
     
      setState(() {
        _predictions = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _getPlaceDetailsAndSetLocation(
      Map<String, dynamic> predictionMap) async {
    setState(() {
      _isLoading = true; // Show loading when fetching details
    });
    try {
      final tempLocationModel = LocationModel.fromPredictionMap(predictionMap);
      final locationController = ref.read(locationControllerProvider);
      final detailedLocation = await locationController
          .fetchCoordinateFromPlaceId(tempLocationModel);

      final notifier = ref.read(rideLocationProvider.notifier);
      if (widget.isPickupLocation) {
        notifier.setPickUpLocation(detailedLocation);
      } else {
        notifier.setDropOffLocation(detailedLocation);
      }
      
      Navigator.of(context).pop(detailedLocation);  // Go back to the previous screen
    } catch (e) {
   
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location details: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading when done
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EmptyAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              cursorColor: Colors.grey,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.isPickupLocation
                    ? 'Search Pick-up Location'
                    : 'Search Drop-off Location',
                prefixIcon: const Icon(Icons.location_pin, color: AppColors.lightgrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[800],
                hintStyle: TextStyle(color: Colors.grey.shade100),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          // --- Finer Loading Indicator ---
          if (_isLoading)
            LinearProgressIndicator(
              color: AppColors.primary, // Use your app's primary color
              backgroundColor: Colors.grey[800],
            )
          else
            const SizedBox.shrink(), // No indicator if not loading

          Expanded(
            child: _predictions.isEmpty && !_isLoading && _searchController.text.isNotEmpty
                ? Center(
                    child: AppText.body(
                      'No results found. Try a different search.',
                      color: Colors.grey,
                    ),
                  )
                : _predictions.isEmpty && !_isLoading && _searchController.text.isEmpty
                  ? Center(
                      child: AppText.body(
                        'Start typing to search for locations.',
                        color: Colors.grey,
                      ),
                    )
                  : ListView.builder(
                    itemCount: _predictions.length,
                    itemBuilder: (context, index) {
                      final prediction = _predictions[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on, color: AppColors.primary), // Consistent icon color
                        title: AppText.button(
                          prediction['description'] ?? 'No description',fontSize: 14,
                        ),
                        // subtitle: AppText.caption(
                        //   prediction['structured_formatting']?['secondary_text'] ?? '',
                        // ),
                        onTap: () {
                          if (prediction['place_id'] != null) {
                            _getPlaceDetailsAndSetLocation(prediction);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}