// lib/features/store/model/product_model.dart
// (Confirming your provided model structure)

import 'package:intl/intl.dart'; // Import the intl package
import 'package:starter_codes/features/store/model/store_model.dart'; // For StoreAvatar

class Product {
  final String id;
  final String title;
  final int price;
  final String? description;
  final ProductStore? store; // Changed to ProductStore object, made nullable for flexibility
  final ProductImage? image; // Made nullable for flexibility
  final String category;
  final String? createdAt; // Nullable
  final String? updatedAt; // Nullable
  final String slug;
  final int? v; // Version key, nullable
  int quantity; // Added quantity as a final property with a default value

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.description,
    this.store,
    this.image,
    required this.category,
    this.createdAt,
    this.updatedAt,
    required this.slug,
    this.v,
    this.quantity = 0, // Set default value to 0
  });

  String get formattedPrice {
    final formatCurrency = NumberFormat.currency(
      locale: 'en_NG', // English, Nigeria for Naira symbol
      symbol: '₦', // Explicitly set Naira symbol
      decimalDigits: 2, // Ensure 2 decimal places
    );
    return formatCurrency.format(price.toDouble());
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String,
      title: json['title'] as String,
      price: json['price'] as int,
      description: json['description'] as String?,
      store: json['store'] != null
          ? ProductStore.fromJson(json['store'] as Map<String, dynamic>)
          : null,
      image: json['image'] != null
          ? ProductImage.fromJson(json['image'] as Map<String, dynamic>)
          : null,
      category: json['category'] as String,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      slug: json['slug'] as String,
      v: json['__v'] as int?,
      quantity: json['quantity'] as int? ?? 0, // Parse from JSON or default to 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'price': price,
      'description': description,
      'store': store?.toJson(),
      'image': image?.toJson(),
      'category': category,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'slug': slug,
      '__v': v,
      'quantity': quantity, // Include in toJson
    };
  }

  Product copyWith({
    String? id,
    String? title,
    int? price,
    String? description,
    ProductStore? store,
    ProductImage? image,
    String? category,
    String? createdAt,
    String? updatedAt,
    String? slug,
    int? v,
    int? quantity, // Add to copyWith
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      store: store ?? this.store,
      image: image ?? this.image,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      slug: slug ?? this.slug,
      v: v ?? this.v,
      quantity: quantity ?? this.quantity, // Copy quantity
    );
  }
}

class ProductImage {
  final String imageUrl;
  final String cloudinaryId;

  ProductImage({
    required this.imageUrl,
    required this.cloudinaryId,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      imageUrl: json['imageUrl'] as String,
      cloudinaryId: json['cloudinaryId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'cloudinaryId': cloudinaryId,
    };
  }

  ProductImage copyWith({
    String? imageUrl,
    String? cloudinaryId,
  }) {
    return ProductImage(
      imageUrl: imageUrl ?? this.imageUrl,
      cloudinaryId: cloudinaryId ?? this.cloudinaryId,
    );
  }
}

class ProductStore {
  final String id;
  final String email;
  final String role;
  final String address;
  final String name;
  final String phone;
  final StoreAvatar? avatar; // Re-using StoreAvatar from store_model.dart

  ProductStore({
    required this.id,
    required this.email,
    required this.role,
    required this.address,
    required this.name,
    required this.phone,
    this.avatar,
  });

  factory ProductStore.fromJson(Map<String, dynamic> json) {
    return ProductStore(
      id: json['_id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      address: json['address'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
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

class SingleProductResponse {
  final Product product; // The actual product data

  SingleProductResponse({
    required this.product,
  });

  factory SingleProductResponse.fromJson(Map<String, dynamic> json) {
    return SingleProductResponse(
      product:
          Product.fromJson(json['data']['product'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'product': product.toJson(),
      },
    };
  }

  SingleProductResponse copyWith({
    Product? product,
  }) {
    return SingleProductResponse(
      product: product ?? this.product,
    );
  }
}