/// Google Maps JSON style used by the location picker.
///
/// Tuned for street-level picking: administrative strokes off, roads, POIs and
/// transit stations on, so the user can recognise where the pin actually is.
const String kStreetFocusedMapStyle = '''
[
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels",
    "stylers": [{"visibility": "on"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {"visibility": "on"},
      {"color": "#ffffff"}
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels",
    "stylers": [{"visibility": "on"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {"visibility": "on"},
      {"weight": 2}
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry",
    "stylers": [
      {"visibility": "on"},
      {"weight": 1}
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.icon",
    "stylers": [{"visibility": "on"}]
  },
  {
    "featureType": "poi.business",
    "stylers": [{"visibility": "on"}]
  },
  {
    "featureType": "transit.station",
    "stylers": [{"visibility": "on"}]
  },
  {
    "featureType": "landscape.man_made",
    "stylers": [
      {"visibility": "on"},
      {"color": "#f0f0f0"}
    ]
  }
]
''';
