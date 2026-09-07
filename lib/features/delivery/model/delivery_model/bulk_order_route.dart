import 'package:equatable/equatable.dart';
// import 'package:intl/intl.dart'; // Uncomment if you use DateFormat for date/time parsing

// --- Bulk Order Sub-Models ---

// The legs of a batch order: where it stops, and who to reach at each stop.

class BulkLocationPoint extends Equatable {
  final double? lat;
  final double? lng;
  final String? address;

  const BulkLocationPoint({this.lat, this.lng, this.address});

  factory BulkLocationPoint.fromJson(Map<String, dynamic> json) {
    return BulkLocationPoint(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'address': address,
      };

  @override
  List<Object?> get props => [lat, lng, address];
}

class BulkContact extends Equatable {
  final BulkLocationPoint? location;
  final String? contact;
  final String? name;

  const BulkContact({this.location, this.contact, this.name});

  factory BulkContact.fromJson(Map<String, dynamic> json) {
    return BulkContact(
      location: json['location'] is Map<String, dynamic>
          ? BulkLocationPoint.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      contact: json['contact'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'location': location?.toJson(),
        'contact': contact,
        'name': name,
      };

  @override
  List<Object?> get props => [location, contact, name];
}

class BulkOrderRoute extends Equatable {
  final BulkContact? from;
  final BulkContact? to;
  final double? distance;
  final String? id;

  const BulkOrderRoute({this.from, this.to, this.distance, this.id});

  factory BulkOrderRoute.fromJson(Map<String, dynamic> json) {
    return BulkOrderRoute(
      from: json['from'] is Map<String, dynamic>
          ? BulkContact.fromJson(json['from'] as Map<String, dynamic>)
          : null,
      to: json['to'] is Map<String, dynamic>
          ? BulkContact.fromJson(json['to'] as Map<String, dynamic>)
          : null,
      distance: (json['distance'] as num?)?.toDouble(),
      id: json['_id'] as String? ?? json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'from': from?.toJson(),
        'to': to?.toJson(),
        'distance': distance,
        '_id': id,
      };

  @override
  List<Object?> get props => [from, to, distance, id];
}

// --- Nested Models ---
