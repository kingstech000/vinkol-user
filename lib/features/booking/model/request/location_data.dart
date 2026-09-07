// The shapes a place or an unregistered sender takes in a request body.

class LocationData {
  final String lat;
  final String lng;
  final String address;

  LocationData({
    required this.lat,
    required this.lng,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      lat: json['lat'] as String,
      lng: json['lng'] as String,
      address: json['address'] as String,
    );
  }

  LocationData copyWith({
    String? lat,
    String? lng,
    String? address,
  }) {
    return LocationData(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
    );
  }
}

class LatLngNumber {
  final double lat;
  final double lng;
  final String? address;

  LatLngNumber({
    required this.lat,
    required this.lng,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'lat': lat.toString(),
      'lng': lng.toString(),
    };
    if (address != null) data['address'] = address;
    return data;
  }

  factory LatLngNumber.fromJson(Map<String, dynamic> json) {
    return LatLngNumber(
      lat: (json['lat'] is String
          ? double.tryParse(json['lat'] as String) ?? 0.0
          : (json['lat'] as num).toDouble()),
      lng: (json['lng'] is String
          ? double.tryParse(json['lng'] as String) ?? 0.0
          : (json['lng'] as num).toDouble()),
      address: json['address'] as String?,
    );
  }
}

class Guest {
  final String email;
  final String firstname;
  final String lastname;
  final String phone;

  Guest({
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
    };
  }

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      email: json['email'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      phone: json['phone'] as String,
    );
  }
}
