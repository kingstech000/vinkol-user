// lib/features/store/model/store_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    );
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
