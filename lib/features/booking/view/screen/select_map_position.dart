// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:starter_codes/features/booking/model/location_model.dart';

// class SelectMapPosition extends ConsumerStatefulWidget {
//   @override
//   _SelectMapPositionState createState() => _SelectMapPositionState();
// }

// class _SelectMapPositionState extends ConsumerState<SelectMapPosition> {
//   GoogleMapController? mapController;
//   LatLng? selectedPosition;
//   LatLng? initialPosition;
//   String? address;
//   LocationModel? selectedLocation;
//   bool fetching = false;
//   @override
//   void initState() {
//     super.initState();
//     final currentLocation = ref.read(locat).currentLocation;
//     if (currentLocation != null) {
//       initialPosition =
//           LatLng(currentLocation.latitude, currentLocation.longitude);
//     } else {
//       _getCurrentLocation();
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       setState(() {
//         fetching = true;
//       });
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         initialPosition = LatLng(position.latitude, position.longitude);
//         selectedPosition = initialPosition;
//         _getAddressFromLatLng(initialPosition!);
//       });
//     } catch (e) {
//     } finally {
//       setState(() {
//         fetching = false;
//       });
//     }
//   }

//   Future<void> _getAddressFromLatLng(LatLng position) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//       if (placemarks.isNotEmpty) {
//         Placemark placemark = placemarks.first;
//         setState(() {
//           address = _formatAddress(placemark);
//           selectedLocation = LocationModel(
//             address: address!,
//             coordinates: position,
//           );
//         });
//       } else {
//         setState(() {
//           address = "Address not found";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         address = 'Error fetching address';
//       });
//       print('ERROR: ${e.toString()}');
//     }
//   }

//   String _formatAddress(Placemark placemark) {
//     if (placemark.street == "Unnamed Road" || placemark.street == null) {
//       return "${placemark.locality}, ${placemark.country}";
//     }
//     return "${placemark.street}, ${placemark.locality}, ${placemark.country}";
//   }

//   void _onCameraIdle() async {
//     if (mapController != null) {
//       LatLng target = await mapController!.getLatLng(
//         ScreenCoordinate(
//           x: MediaQuery.of(context).size.width ~/ 2,
//           y: MediaQuery.of(context).size.height ~/ 2,
//         ),
//       );

//       _getAddressFromLatLng(target);
//     }
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: initialPosition == null
//           ? const Center(child: CustomCircularProgressIndicator())
//           : Stack(
//               children: [
//                 GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: initialPosition!,
//                     zoom: 15,
//                   ),
//                   onCameraIdle: _onCameraIdle,
//                   onMapCreated: _onMapCreated,
//                   mapToolbarEnabled: false,
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: false,
//                 ),
//                 Center(
//                   child:
//                       Icon(CupertinoIcons.map_pin, color: kPikaColor, size: 70),
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 20),
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: Theme.of(context).colorScheme.background),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           address ?? 'Fetching address...',
//                           style: Theme.of(context).textTheme.titleMedium,
//                           maxLines: 2,
//                           softWrap: true,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         fetching
//                             ? CustomLinearIndicator(color: kPikaColor)
//                             : ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: kPikaColor),
//                                 onPressed: () async {
//                                   await _getCurrentLocation();
//                                   if (selectedLocation != null) {
//                                     Navigator.of(context)
//                                         .pop(selectedLocation!);
//                                   }
//                                 },
//                                 child: Text('Select this location',
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .titleSmall!
//                                         .copyWith(color: Colors.white)),
//                               ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
