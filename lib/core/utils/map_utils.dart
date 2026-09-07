import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String googleApiKey = dotenv.env['GOOGLE_MAP_API_KEY'] as String;

Future<List<LatLng>> createPolyline({
  required PointLatLng pickup,
  required PointLatLng dropOff,
}) async {
  final polylinePoints = PolylinePoints();
  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    googleApiKey: googleApiKey,
    request: PolylineRequest(
      origin: pickup,
      destination: dropOff,
      mode: TravelMode.driving,
    ),
  );

  if (result.points.isNotEmpty) {
    print('POLYLINE POINTS: ${result.points}');
    return result.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  } else {
    print('FAILED TO GET POLYLINE POINTS');
    return [];
  }
}

void addPolyline({
  required Set<Polyline> polylines,
  required List<LatLng> polylineCoordinates,
  String polylineId = 'route',
  Color color = Colors.blueAccent,
  int width = 4,
  JointType jointType = JointType.round,
  Cap startCap = Cap.roundCap,
  Cap endCap = Cap.roundCap,
}) {
  polylines.add(
    Polyline(
      polylineId: PolylineId(polylineId),
      points: polylineCoordinates,
      color: color,
      width: width,
      jointType: jointType,
      startCap: startCap,
      endCap: endCap,
    ),
  );
}

// void openGoogleMapsNavigation(double latitude, double longitude) async {
//   final url = Uri.parse(
//       'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving');

//   if (await canLaunchUrl(url)) {
//     await launchUrl(url, mode: LaunchMode.externalApplication);
//   } else {
//     throw 'Could not launch Google Maps';
//   }
// }

Future<void> openGoogleMapsDirections(
    String? origin, String? destination) async {
  if (origin == null || destination == null) {
    throw 'Origin and destination addresses are required';
  }

  // URL encode the addresses
  final encodedOrigin = Uri.encodeComponent(origin);
  final encodedDestination = Uri.encodeComponent(destination);

  final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$encodedOrigin&destination=$encodedDestination&travelmode=driving');

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch Google Maps';
  }
}

String calculateDistanceInKm(
    {required LatLng initialLoc, required LatLng finalLoc}) {
  const double earthRadius = 6371;
  double initialLatRad = _toRadians(initialLoc.latitude);
  double finalLatRad = _toRadians(finalLoc.latitude);
  double deltaLatRad = _toRadians(finalLoc.latitude - initialLoc.latitude);
  double deltaLonRad = _toRadians(finalLoc.longitude - initialLoc.longitude);

  double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
      cos(initialLatRad) *
          cos(finalLatRad) *
          sin(deltaLonRad / 2) *
          sin(deltaLonRad / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  // Distance in kilometers
  double distance = earthRadius * c;

  return distance.toStringAsFixed(2);
}

double _toRadians(double degree) {
  return degree * (pi / 180);
}

/// The bounds containing every point in [points].
///
/// Extracted from the three quote screens, which each carried an identical
/// `_boundsFromLatLngList`; two of them force-unwrapped the accumulators and threw on an
/// empty list. Returns null here instead, so the caller decides what an empty route means.
LatLngBounds? boundsFor(List<LatLng> points) {
  if (points.isEmpty) return null;

  double south = points.first.latitude;
  double north = points.first.latitude;
  double west = points.first.longitude;
  double east = points.first.longitude;

  for (final LatLng point in points) {
    if (point.latitude < south) south = point.latitude;
    if (point.latitude > north) north = point.latitude;
    if (point.longitude < west) west = point.longitude;
    if (point.longitude > east) east = point.longitude;
  }

  return LatLngBounds(
    southwest: LatLng(south, west),
    northeast: LatLng(north, east),
  );
}

/// The driving route between two points, falling back to a straight line.
///
/// The Directions call fails on a rate limit, a missing key or a pair of points with no road
/// between them. A straight line is wrong but legible; drawing nothing leaves the user
/// looking at two unconnected pins and no sense of the trip.
Future<List<LatLng>> routeBetween(LatLng origin, LatLng destination) async {
  try {
    final List<LatLng> points = await createPolyline(
      pickup: PointLatLng(origin.latitude, origin.longitude),
      dropOff: PointLatLng(destination.latitude, destination.longitude),
    );
    if (points.isNotEmpty) return points;
  } catch (e) {
    debugPrint('routeBetween: falling back to a straight line — $e');
  }
  return <LatLng>[origin, destination];
}
