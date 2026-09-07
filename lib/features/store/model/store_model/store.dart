// lib/features/store/model/store_model.dart

import 'package:starter_codes/features/store/model/store_model.dart';

// A store and its branding.

class Store {
  final String id;
  final String? email;
  final bool? isEmailVerified;
  final String? role;
  final String? createdAt;
  final String? updatedAt;
  final String? address;
  final String? bio;
  final String? name;
  final String? phone;
  final String? state;
  final StoreAvatar? avatar;
  final String? lga;
  final double? lat;
  final double? lng;
  final OpeningHours? openingHours;

  Store({
    required this.id,
    this.email,
    this.isEmailVerified,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.address,
    this.bio,
    this.name,
    this.phone,
    this.state,
    this.avatar,
    this.lga,
    this.lat,
    this.lng,
    this.openingHours,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['_id'] as String,
      email: json['email'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool?,
      role: json['role'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      address: json['address'] as String?,
      bio: json['bio'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      state: json['state'] as String?,
      avatar: json['avatar'] != null
          ? StoreAvatar.fromJson(json['avatar'] as Map<String, dynamic>)
          : null,
      lga: json['lga'] as String?,
      // Handle lat/lng which might be String or num, defaulting to null
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      openingHours: json['openingHours'] != null
          ? OpeningHours.fromJson(json['openingHours'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'address': address,
      'bio': bio,
      'name': name,
      'phone': phone,
      'state': state,
      'avatar': avatar?.toJson(),
      'lga': lga,
      'lat': lat,
      'lng': lng,
      'openingHours': openingHours?.toJson(),
    };
  }

  Store copyWith({
    String? id,
    String? email,
    bool? isEmailVerified,
    String? role,
    String? createdAt,
    String? updatedAt,
    String? address,
    String? bio,
    String? name,
    String? phone,
    String? state,
    StoreAvatar? avatar,
    String? lga,
    double? lat,
    double? lng,
    OpeningHours? openingHours,
  }) {
    return Store(
      id: id ?? this.id,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      state: state ?? this.state,
      avatar: avatar ?? this.avatar,
      lga: lga ?? this.lga,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      openingHours: openingHours ?? this.openingHours,
    );
  }

  /// Check if store is currently open
  bool get isOpen {
    if (openingHours == null) {
      // If no opening hours data, default to open (backward compatibility)
      return true;
    }
    return openingHours!.isOpenToday();
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}

class StoreAvatar {
  final String imageUrl;
  final String cloudinaryId;

  StoreAvatar({
    required this.imageUrl,
    required this.cloudinaryId,
  });

  factory StoreAvatar.fromJson(Map<String, dynamic> json) {
    return StoreAvatar(
      imageUrl: json['imageUrl'] as String? ?? '', // Default to empty string
      cloudinaryId:
          json['cloudinaryId'] as String? ?? '', // Default to empty string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'cloudinaryId': cloudinaryId,
    };
  }

  StoreAvatar copyWith({
    String? imageUrl,
    String? cloudinaryId,
  }) {
    return StoreAvatar(
      imageUrl: imageUrl ?? this.imageUrl,
      cloudinaryId: cloudinaryId ?? this.cloudinaryId,
    );
  }
}
// lib/features/store/model/store_product_model.dart
