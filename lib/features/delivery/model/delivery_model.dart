import 'package:equatable/equatable.dart';
// import 'package:intl/intl.dart'; // Uncomment if you use DateFormat for date/time parsing

// --- Nested Models ---

class UserOrderModel extends Equatable {
  final String? id;
  final String? email;
  final String? firstname;
  final String? lastname;
  final String? phone;
  final String? imageUrl; // Direct access to avatar imageUrl

  const UserOrderModel({
    this.id,
    this.email,
    this.firstname,
    this.lastname,
    this.phone,
    this.imageUrl,
  });

  factory UserOrderModel.fromJson(Map<String, dynamic> json) {
    return UserOrderModel(
      id: json['_id'] as String?,
      email: json['email'] as String?,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      phone: json['phone'] as String?,
      imageUrl:
          (json['avatar'] as Map<String, dynamic>?)?['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'avatar': {
        'imageUrl': imageUrl,
      },
    };
  }

  String get fullName {
    if (firstname != null && lastname != null) {
      return '$firstname $lastname';
    } else if (firstname != null) {
      return firstname!;
    } else if (lastname != null) {
      return lastname!;
    } else {
      return 'Unknown User';
    }
  }

  @override
  List<Object?> get props => [id, email, firstname, lastname, phone, imageUrl];
}

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

class AgentModel extends Equatable {
  final String? id;
  final String? email;
  final String? firstname;
  final String? lastname;
  final String? phone;
  final String? imageUrl; // Direct access to avatar imageUrl

  const AgentModel({
    this.id,
    this.email,
    this.firstname,
    this.lastname,
    this.phone,
    this.imageUrl,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['_id'] as String?,
      email: json['email'] as String?,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      phone: json['phone'] as String?,
      imageUrl:
          (json['avatar'] as Map<String, dynamic>?)?['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'avatar': {
        'imageUrl': imageUrl,
      },
    };
  }

  String get fullName {
    if (firstname != null && lastname != null) {
      return '$firstname $lastname';
    } else if (firstname != null) {
      return firstname!;
    } else if (lastname != null) {
      return lastname!;
    } else {
      return 'Unknown Agent';
    }
  }

  @override
  List<Object?> get props => [id, email, firstname, lastname, phone, imageUrl];
}

// --- Main DeliveryModel ---

class DeliveryModel extends Equatable {
  final String? id;
  final UserOrderModel? user;
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? state;
  final String? status;
  final String? deliveryType;
  final String? orderType;
  final double? amount;
  final double? deliveryFee;
  final String? paystackReference;
  final String? paymentStatus;
  final List<ProductModel>? products;
  final StoreModel? store;
  final int? orderOtp;
  final String? trackingId;
  final double? totalAmount;
  final String? description;
  final String? note;
  final AgentModel? deliveryAgent;
  final String? vehicleRequest;
  final String? vehicleType;
  final String? date;
  final String? time;

  const DeliveryModel({
    this.id,
    this.user,
    this.pickupLocation,
    this.dropoffLocation,
    this.state,
    this.status,
    this.deliveryType,
    this.orderType,
    this.amount,
    this.deliveryFee,
    this.paystackReference,
    this.paymentStatus,
    this.products,
    this.store,
    this.orderOtp,
    this.trackingId,
    this.totalAmount,
    this.deliveryAgent,
    this.vehicleRequest,
    this.vehicleType,
    this.date,
    this.time,
    this.description,
    this.note,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    AgentModel? agent;
    if (json['rider'] is Map<String, dynamic>) {
      agent = AgentModel.fromJson(json['rider'] as Map<String, dynamic>);
    } else if (json['shopper'] is Map<String, dynamic>) {
      agent = AgentModel.fromJson(json['shopper'] as Map<String, dynamic>);
    }

    // --- FIXES FOR POTENTIAL STRING TO NUM TYPE CAST ISSUES ---

    int? parsedOrderOtp;
    if (json['orderOtp'] != null) {
      if (json['orderOtp'] is int) {
        parsedOrderOtp = json['orderOtp'] as int;
      } else if (json['orderOtp'] is String) {
        parsedOrderOtp = int.tryParse(json['orderOtp'] as String);
      }
    }

    double? parsedAmount;
    if (json['amount'] != null) {
      if (json['amount'] is num) {
        parsedAmount = (json['amount'] as num).toDouble();
      } else if (json['amount'] is String) {
        parsedAmount = double.tryParse(json['amount'] as String);
      }
    }

    double? parsedDeliveryFee;
    if (json['deliveryFee'] != null) {
      if (json['deliveryFee'] is num) {
        parsedDeliveryFee = (json['deliveryFee'] as num).toDouble();
      } else if (json['deliveryFee'] is String) {
        parsedDeliveryFee = double.tryParse(json['deliveryFee'] as String);
      }
    }

    double? parsedTotalAmount;
    if (json['totalAmount'] != null) {
      if (json['totalAmount'] is num) {
        parsedTotalAmount = (json['totalAmount'] as num).toDouble();
      } else if (json['totalAmount'] is String) {
        parsedTotalAmount = double.tryParse(json['totalAmount'] as String);
      }
    }

    return DeliveryModel(
        id: json['_id'] as String?,
        user: json['user'] is Map<String, dynamic>
            ? UserOrderModel.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        pickupLocation: json['pickupLocation'] as String?,
        dropoffLocation: json['dropoffLocation'] as String?,
        state: json['state'] as String?,
        status: json['status'] as String?,
        deliveryType: json['deliveryType'] as String?,
        orderType: json['orderType'] as String?,
        amount: parsedAmount, // Use the parsed amount
        deliveryFee: parsedDeliveryFee, // Use the parsed deliveryFee
        paystackReference: json['paystackReference'] as String?,
        paymentStatus: json['paymentStatus'] as String?,
        products: (json['products'] as List<dynamic>?)
            ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        store: json['store'] is Map<String, dynamic>
            ? StoreModel.fromJson(json['store'] as Map<String, dynamic>)
            : null,
        orderOtp: parsedOrderOtp, // Use the parsed orderOtp
        trackingId: json['trackingId'] as String?,
        totalAmount: parsedTotalAmount, // Use the parsed totalAmount
        deliveryAgent: agent,
        vehicleRequest: json['vehicleRequest'] as String?,
        vehicleType: json['vehicleType'] as String?,
        description: json['description'] as String?,
        time: json['time'],
        date: json['date'],
        note: json['note'] as String?);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      '_id': id,
      'user': user?.toJson(),
      'dropoffLocation': dropoffLocation,
      'state': state,
      'status': status,
      'deliveryType': deliveryType,
      'orderType': orderType,
      'amount': amount,
      'deliveryFee': deliveryFee,
      'paystackReference': paystackReference,
      'paymentStatus': paymentStatus,
      'products': products?.map((e) => e.toJson()).toList(),
      'store': store?.toJson(),
      'orderOtp': orderOtp,
      'trackingId': trackingId,
      'totalAmount': totalAmount,
    };

    if (pickupLocation != null) jsonMap['pickupLocation'] = pickupLocation;
    if (deliveryAgent != null) {
      jsonMap['deliveryAgent'] = deliveryAgent!.toJson();
    }
    if (vehicleRequest != null) jsonMap['vehicleRequest'] = vehicleRequest;
    if (vehicleType != null) jsonMap['vehicleType'] = vehicleType;

    return jsonMap;
  }

  @override
  List<Object?> get props => [
        id,
        user,
        pickupLocation,
        dropoffLocation,
        state,
        status,
        deliveryType,
        orderType,
        amount,
        deliveryFee,
        paystackReference,
        paymentStatus,
        products,
        store,
        orderOtp,
        trackingId,
        totalAmount,
        deliveryAgent,
        vehicleRequest,
        vehicleType,
        date,
        time,
      ];

  int get totalItemsOrdered {
    if (products == null || products!.isEmpty) {
      return 0;
    }
    return products!
        .fold<int>(0, (sum, product) => sum + (product.quantity ?? 0));
  }

  DeliveryModel copyWith({
    String? id,
    UserOrderModel? user,
    String? pickupLocation,
    String? dropoffLocation,
    String? state,
    String? status,
    String? deliveryType,
    String? orderType,
    double? amount,
    double? deliveryFee,
    String? paystackReference,
    String? paymentStatus,
    List<ProductModel>? products,
    StoreModel? store,
    int? orderOtp,
    String? trackingId,
    double? totalAmount,
    AgentModel? deliveryAgent,
    String? vehicleRequest,
    String? vehicleType,
    String? date,
    String? time,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      user: user ?? this.user,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      state: state ?? this.state,
      status: status ?? this.status,
      deliveryType: deliveryType ?? this.deliveryType,
      orderType: orderType ?? this.orderType,
      amount: amount ?? this.amount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      paystackReference: paystackReference ?? this.paystackReference,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      products: products ?? this.products,
      store: store ?? this.store,
      orderOtp: orderOtp ?? this.orderOtp,
      trackingId: trackingId ?? this.trackingId,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryAgent: deliveryAgent ?? this.deliveryAgent,
      vehicleRequest: vehicleRequest ?? this.vehicleRequest,
      vehicleType: vehicleType ?? this.vehicleType,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}

// --- Response Wrapper (still named DeliveriesResponse as per your original) ---

class DeliveriesResponse extends Equatable {
  final bool success;
  final String message;
  final List<DeliveryModel> data;

  DeliveriesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DeliveriesResponse.fromJson(Map<String, dynamic> json) {
    return DeliveriesResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'No message',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => DeliveryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [success, message, data];
}
