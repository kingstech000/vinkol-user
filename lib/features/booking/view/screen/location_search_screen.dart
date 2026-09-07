import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/view/widget/location_search/location_search_header.dart';
import 'package:starter_codes/features/booking/view/widget/location_search/location_search_results.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/provider/location_provider.dart';

class LocationSearchScreen extends ConsumerStatefulWidget {
  final bool isPickupLocation;
  final String? stopId;

  const LocationSearchScreen(
      {super.key, required this.isPickupLocation, this.stopId});

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
    _searchController.addListener(() {
      setState(() {}); // Update UI when text changes for clear button
      _onSearchChanged();
    });
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
      if (mounted) {
        setState(() {
          _predictions = [];
          _isLoading = false; // Ensure loading is off if input is empty
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final locationController = ref.read(locationControllerProvider);
      final results = await locationController.searchPlaces(
        input,
      );

      if (mounted) {
        setState(() {
          _predictions = results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _predictions = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _getPlaceDetailsAndSetLocation(
      Map<String, dynamic> predictionMap) async {
    if (mounted) {
      setState(() {
        _isLoading = true; // Show loading when fetching details
      });
    }
    try {
      final tempLocationModel = LocationModel.fromPredictionMap(predictionMap);
      final locationController = ref.read(locationControllerProvider);
      final detailedLocation = await locationController
          .fetchCoordinateFromPlaceId(tempLocationModel);

      final notifier = ref.read(rideLocationProvider.notifier);
      if (widget.stopId != null) {
        notifier.updateStopLocation(widget.stopId!, detailedLocation);
      } else {
        if (widget.isPickupLocation) {
          notifier.setPickUpLocation(detailedLocation);
        } else {
          notifier.setDropOffLocation(detailedLocation);
        }
      }

      if (mounted) {
        Navigator.of(context)
            .pop(detailedLocation); // Go back to the previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location details: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading when done
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: InkWell(
          splashColor: AppColors.white,
          highlightColor: AppColors.white,
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.white,
              Colors.white,
            ],
            stops: const [0.0, 0.2, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              LocationSearchHeader(
                isPickupLocation: widget.isPickupLocation,
                controller: _searchController,
              ),
              if (_isLoading)
                SizedBox(
                  height: 3.h,
                  child: LinearProgressIndicator(
                    color: AppColors.primary,
                    backgroundColor: Colors.grey[200],
                    minHeight: 3.h,
                  ),
                )
              else
                SizedBox(height: 3.h),
              Expanded(
                child: LocationSearchResults(
                  isLoading: _isLoading,
                  predictions: _predictions,
                  searchText: _searchController.text,
                  onSelect: _getPlaceDetailsAndSetLocation,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
