// lib/features/booking/model/order_model.dart

// Coordinates as the quote endpoints express them.

class LatLngLiteral {
  final double lat;
  final double lng;

  LatLngLiteral({required this.lat, required this.lng});

  factory LatLngLiteral.fromJson(Map<String, dynamic> json) {
    double parsedLat;
    var latValue = json['lat'];
    if (latValue is num) {
      parsedLat = latValue.toDouble();
    } else if (latValue is String) {
      parsedLat = double.tryParse(latValue) ?? 0.0;
    } else {
      parsedLat = 0.0;
    }

    double parsedLng;
    var lngValue = json['lng'];
    if (lngValue is num) {
      parsedLng = lngValue.toDouble();
    } else if (lngValue is String) {
      parsedLng = double.tryParse(lngValue) ?? 0.0;
    } else {
      parsedLng = 0.0;
    }

    return LatLngLiteral(
      lat: parsedLat,
      lng: parsedLng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

class LatLngWithAddress {
  final double lat;
  final double lng;
  final String? address;

  LatLngWithAddress({
    required this.lat,
    required this.lng,
    this.address,
  });

  factory LatLngWithAddress.fromJson(Map<String, dynamic> json) {
    return LatLngWithAddress(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'lat': lat,
      'lng': lng,
    };
    if (address != null) data['address'] = address;
    return data;
  }
}

class RouteEndpoint {
  final LatLngWithAddress location;
  final String contact;
  final String? name;

  RouteEndpoint({
    required this.location,
    required this.contact,
    this.name,
  });

  factory RouteEndpoint.fromJson(Map<String, dynamic> json) {
    return RouteEndpoint(
      location:
          LatLngWithAddress.fromJson(json['location'] as Map<String, dynamic>),
      contact: json['contact'] as String,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'location': location.toJson(),
      'contact': contact,
    };
    if (name != null) data['name'] = name;
    return data;
  }
}
