import 'package:equatable/equatable.dart';
// import 'package:intl/intl.dart'; // Uncomment if you use DateFormat for date/time parsing

// --- Bulk Order Sub-Models ---

// Store-order line items and the store they came from.

class ProductModel extends Equatable {
  final String?
      id; // This is the _id from the product entry in the order array itself
  final String?
      productId; // This will hold the product ID (e.g., "68657e7da820a66130210f96")
  final String? title; // Product title, available when 'product' is populated
  final int? quantity;
  final double? price; // Price per unit, available when 'product' is populated
  final String?
      imageUrl; // Product image URL, available when 'product' is populated

  const ProductModel({
    this.id,
    this.productId,
    this.title,
    this.quantity,
    this.price,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String? currentProductId;
    String? currentTitle;
    double? currentPrice;
    String? currentImageUrl;

    final dynamic productData = json['product'];

    if (productData is String) {
      currentProductId = productData;
    } else if (productData is Map<String, dynamic>) {
      currentProductId = productData['_id'] as String?;
      currentTitle = productData['title'] as String?;
      // --- POTENTIAL FIX FOR PRODUCT PRICE ---
      if (productData['price'] != null) {
        if (productData['price'] is num) {
          currentPrice = (productData['price'] as num).toDouble();
        } else if (productData['price'] is String) {
          currentPrice = double.tryParse(productData['price'] as String);
        }
      }
      currentImageUrl = (productData['image']
          as Map<String, dynamic>?)?['imageUrl'] as String?;
    }

    // --- POTENTIAL FIX FOR PRODUCT QUANTITY ---
    int? parsedQuantity;
    if (json['quantity'] != null) {
      if (json['quantity'] is int) {
        parsedQuantity = json['quantity'] as int;
      } else if (json['quantity'] is String) {
        parsedQuantity = int.tryParse(json['quantity'] as String);
      }
    }

    return ProductModel(
      id: json['_id'] as String?,
      productId: currentProductId,
      title: currentTitle,
      quantity: parsedQuantity, // Use the parsed quantity
      price: currentPrice, // Use the parsed price
      imageUrl: currentImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'product': productId, // Assuming sending back the ID is sufficient
      'quantity': quantity,
    };
  }

  @override
  List<Object?> get props => [id, productId, title, quantity, price, imageUrl];
}

class StoreModel extends Equatable {
  final String? id;
  final String? email;
  final String? name;
  final String? phone;
  final String? state;
  final String? address;
  final String? imageUrl; // Direct access to avatar imageUrl

  const StoreModel({
    this.id,
    this.email,
    this.name,
    this.phone,
    this.address,
    this.state,
    this.imageUrl,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['_id'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      state: json['state'] as String?,
      address: json['address'] as String?,
      imageUrl:
          (json['avatar'] as Map<String, dynamic>?)?['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'state': state,
      'address': address,
      'avatar': {
        'imageUrl': imageUrl,
      },
    };
  }

  @override
  List<Object?> get props => [id, email, name, phone, state, imageUrl];
}
