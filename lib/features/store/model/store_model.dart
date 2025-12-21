// lib/features/store/model/store_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

class OpeningHours {
  final DayHours? monday;
  final DayHours? tuesday;
  final DayHours? wednesday;
  final DayHours? thursday;
  final DayHours? friday;
  final DayHours? saturday;
  final DayHours? sunday;

  OpeningHours({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      monday: json['monday'] != null
          ? DayHours.fromJson(json['monday'] as Map<String, dynamic>)
          : null,
      tuesday: json['tuesday'] != null
          ? DayHours.fromJson(json['tuesday'] as Map<String, dynamic>)
          : null,
      wednesday: json['wednesday'] != null
          ? DayHours.fromJson(json['wednesday'] as Map<String, dynamic>)
          : null,
      thursday: json['thursday'] != null
          ? DayHours.fromJson(json['thursday'] as Map<String, dynamic>)
          : null,
      friday: json['friday'] != null
          ? DayHours.fromJson(json['friday'] as Map<String, dynamic>)
          : null,
      saturday: json['saturday'] != null
          ? DayHours.fromJson(json['saturday'] as Map<String, dynamic>)
          : null,
      sunday: json['sunday'] != null
          ? DayHours.fromJson(json['sunday'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monday': monday?.toJson(),
      'tuesday': tuesday?.toJson(),
      'wednesday': wednesday?.toJson(),
      'thursday': thursday?.toJson(),
      'friday': friday?.toJson(),
      'saturday': saturday?.toJson(),
      'sunday': sunday?.toJson(),
    };
  }

  /// Check if store is open today
  bool isOpenToday() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday

    DayHours? todayHours;
    switch (dayOfWeek) {
      case 1:
        todayHours = monday;
        break;
      case 2:
        todayHours = tuesday;
        break;
      case 3:
        todayHours = wednesday;
        break;
      case 4:
        todayHours = thursday;
        break;
      case 5:
        todayHours = friday;
        break;
      case 6:
        todayHours = saturday;
        break;
      case 7:
        todayHours = sunday;
        break;
    }

    // If no hours data for today, assume closed
    if (todayHours == null) {
      return false;
    }

    // If isClosed is false, store is open
    return !(todayHours.isClosed ?? true);
  }
}

class DayHours {
  final bool? isClosed;
  final List<dynamic>? hours;

  DayHours({
    this.isClosed,
    this.hours,
  });

  factory DayHours.fromJson(Map<String, dynamic> json) {
    return DayHours(
      isClosed: json['isClosed'] as bool?,
      hours: json['hours'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isClosed': isClosed,
      'hours': hours,
    };
  }
}

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
      cloudinaryId: json['cloudinaryId'] as String? ?? '', // Default to empty string
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


class StoreProductImage {
  final String imageUrl;
  final String cloudinaryId;

  StoreProductImage({
    required this.imageUrl,
    required this.cloudinaryId,
  });

  factory StoreProductImage.fromJson(Map<String, dynamic> json) {
    return StoreProductImage(
      imageUrl: json['imageUrl'] as String? ?? '', // Default to empty string
      cloudinaryId: json['cloudinaryId'] as String? ?? '', // Default to empty string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'cloudinaryId': cloudinaryId,
    };
  }

  StoreProductImage copyWith({
    String? imageUrl,
    String? cloudinaryId,
  }) {
    return StoreProductImage(
      imageUrl: imageUrl ?? this.imageUrl,
      cloudinaryId: cloudinaryId ?? this.cloudinaryId,
    );
  }
}

class ProductStore {
  final String id;
  final String? email;
  final String? role;
  final String? address;
  final String? name;
  final String? phone;
  final StoreAvatar? avatar;

  ProductStore({
    required this.id,
    this.email,
    this.role,
    this.address,
    this.name,
    this.phone,
    this.avatar,
  });

  factory ProductStore.fromJson(Map<String, dynamic> json) {
    return ProductStore(
      id: json['_id'] as String? ?? '', // Default to empty string
      email: json['email'] as String?,
      role: json['role'] as String?,
      address: json['address'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] != null
          ? StoreAvatar.fromJson(json['avatar'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'role': role,
      'address': address,
      'name': name,
      'phone': phone,
      'avatar': avatar?.toJson(),
    };
  }

  ProductStore copyWith({
    String? id,
    String? email,
    String? role,
    String? address,
    String? name,
    String? phone,
    StoreAvatar? avatar,
  }) {
    return ProductStore(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      address: address ?? this.address,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
    );
  }
}



class StoreProduct {
  final String id;
  final String title;
  final int price;
  final String? description;
  final String? store; // Made nullable for safety, might be absent in some contexts
  final StoreProductImage image;
  final String category;
  final String slug;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  int? quantity; // <--- ADD THIS FOR CART FUNCTIONALITY

  StoreProduct({
    required this.id,
    required this.title,
    required this.price,
    this.description,
    this.store,
    required this.image,
    required this.category,
    required this.slug,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.quantity = 0, // <--- Initialize quantity for cart
  });

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      description: json['description'] as String?,
      // --- Focused Null-Safety Enhancement for 'store' ---
      store: json['store'] is String
          ? json['store'] as String
          : '', // Only parse if it's actually a Map, otherwise null
      // -------------------------------------------------
      image: StoreProductImage.fromJson(json['image'] as Map<String, dynamic>? ?? {}),
      category: json['category'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
      quantity: json['quantity'] as int?, // Parse quantity if it comes from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'price': price,
      'description': description,
      'store': store, // Use null-aware operator
      'image': image.toJson(),
      'category': category,
      'slug': slug,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'quantity': quantity, // Include quantity in toJson
    };
  }

  StoreProduct copyWith({
    String? id,
    String? title,
    int? price,
    String? description,
    String? store,
    StoreProductImage? image,
    String? category,
    String? slug,
    String? createdAt,
    String? updatedAt,
    int? v,
    int? quantity, // <--- Add quantity to copyWith
  }) {
    return StoreProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      store: store ?? this.store,
      image: image ?? this.image,
      category: category ?? this.category,
      slug: slug ?? this.slug,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      quantity: quantity ?? this.quantity, // <--- Update quantity
    );
  }
}


final currentStoreProvider = StateProvider<Store?>((ref) => null);
