import 'package:equatable/equatable.dart';
import 'package:starter_codes/core/money/money.dart';
// import 'package:intl/intl.dart'; // Uncomment if you use DateFormat for date/time parsing

// --- Bulk Order Sub-Models ---

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
  final String? createdAt;
  final AgentModel? deliveryAgent;
  final String? vehicleRequest;
  final String? vehicleType;
  final String? date;
  final String? time;

  // --- Bulk order fields ---
  final bool? isBulkOrder;
  final BulkContact? pickup;
  final List<BulkContact>? dropoffs;
  final int? totalOrders;
  final List<BulkOrderRoute>? route;
  final double? walletAmountUsed;
  final String? paymentSource;
  final String? paymentReference;
  final double? riderFee;

  /// Processing fee. Zero on Nigerian plain deliveries.
  final double? serviceFee;

  /// Tax resolved from the delivery's province. Zero in Nigeria.
  final double? taxAmount;

  /// The rate the tax was computed at, e.g. `0.13`.
  final double? taxRate;

  /// What to call the tax on the receipt, e.g. `HST` or `GST + QST`.
  final String? taxLabel;

  /// What the customer was actually charged. Null on records the server has not
  /// itemised, in which case [totalAmount] stands.
  final double? grandTotal;

  /// The market this order belongs to, decided by the server from the pickup
  /// coordinates. Absent on records written before the Canada expansion, all of
  /// which are Nigerian.
  final Country country;
  final Currency currency;

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
    this.createdAt,
    this.description,
    this.note,
    // bulk
    this.isBulkOrder,
    this.pickup,
    this.dropoffs,
    this.totalOrders,
    this.route,
    this.walletAmountUsed,
    this.paymentSource,
    this.paymentReference,
    this.riderFee,
    this.serviceFee,
    this.taxAmount,
    this.taxRate,
    this.taxLabel,
    this.grandTotal,
    this.country = Country.ng,
    this.currency = Currency.ngn,
  });

  /// What the customer was charged. Falls back to the stored total when the
  /// server has not itemised the bill, so Nigerian records render as before.
  Money get amountDue => Money(grandTotal ?? totalAmount ?? 0, currency);

  Money? get deliveryFeeMoney =>
      deliveryFee == null ? null : Money(deliveryFee!, currency);

  Money? get serviceFeeMoney =>
      serviceFee == null ? null : Money(serviceFee!, currency);

  Money? get taxMoney => taxAmount == null ? null : Money(taxAmount!, currency);

  bool get hasItemisedCharges => (serviceFee ?? 0) > 0 || (taxAmount ?? 0) > 0;

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
    // Fallback for amount
    if (parsedAmount == null || parsedAmount == 0.0) {
      final alts = ['itemsTotal', 'subTotal', 'price', 'subtotal'];
      for (final key in alts) {
        if (json[key] != null) {
          if (json[key] is num) {
            parsedAmount = (json[key] as num).toDouble();
          } else if (json[key] is String) {
            parsedAmount = double.tryParse(json[key]);
          }
          if (parsedAmount != null && parsedAmount != 0.0) break;
        }
      }
    }

    // Fallback for amount: if still null, default to 0.0 for calculation purposes
    parsedAmount ??= 0.0;

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
    // Fallback for totalAmount: check 'total_amount' or sum
    if (parsedTotalAmount == null) {
      if (json['total_amount'] != null) {
        if (json['total_amount'] is num) {
          parsedTotalAmount = (json['total_amount'] as num).toDouble();
        } else if (json['total_amount'] is String) {
          parsedTotalAmount = double.tryParse(json['total_amount']);
        }
      }
    }
    // Final fallback: Calculate totalAmount if amount and fee exist
    if ((parsedTotalAmount == null || parsedTotalAmount == 0.0) &&
        parsedDeliveryFee != null) {
      parsedTotalAmount = parsedAmount + parsedDeliveryFee;
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
        amount: parsedAmount,
        deliveryFee: parsedDeliveryFee,
        paystackReference: json['paystackReference'] as String?,
        paymentStatus: json['paymentStatus'] as String?,
        products: (json['products'] as List<dynamic>?)
            ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        store: json['store'] is Map<String, dynamic>
            ? StoreModel.fromJson(json['store'] as Map<String, dynamic>)
            : null,
        orderOtp: parsedOrderOtp,
        trackingId: json['trackingId'] as String?,
        totalAmount: parsedTotalAmount,
        deliveryAgent: agent,
        vehicleRequest: json['vehicleRequest'] as String?,
        vehicleType: json['vehicleType'] as String?,
        description: json['description'] as String?,
        time: json['time'],
        date: json['date'],
        createdAt: json['createdAt'],
        note: json['note'] as String?,
        // bulk order fields
        isBulkOrder: json['isBulkOrder'] as bool?,
        pickup: json['pickup'] is Map<String, dynamic>
            ? BulkContact.fromJson(json['pickup'] as Map<String, dynamic>)
            : null,
        dropoffs: (json['dropoffs'] as List<dynamic>?)
            ?.map((e) => BulkContact.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalOrders: json['totalOrders'] as int?,
        route: (json['route'] as List<dynamic>?)
            ?.map((e) => BulkOrderRoute.fromJson(e as Map<String, dynamic>))
            .toList(),
        walletAmountUsed: (json['walletAmountUsed'] as num?)?.toDouble(),
        paymentSource: json['paymentSource'] as String?,
        paymentReference: json['paymentReference'] as String?,
        riderFee: (json['riderFee'] as num?)?.toDouble(),
        serviceFee: Money.parseAmount(json['serviceFee']),
        taxAmount: Money.parseAmount(json['taxAmount']),
        taxRate: Money.parseAmount(json['taxRate']),
        taxLabel: json['taxLabel'] as String?,
        grandTotal: Money.parseAmount(json['grandTotal']),
        country: Country.fromCode(json['country'] as String?),
        currency: Currency.fromCode(json['currency'] as String?));
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
      'country': country.code,
      'currency': currency.code,
      if (serviceFee != null) 'serviceFee': serviceFee,
      if (taxAmount != null) 'taxAmount': taxAmount,
      if (taxRate != null) 'taxRate': taxRate,
      if (taxLabel != null) 'taxLabel': taxLabel,
      if (grandTotal != null) 'grandTotal': grandTotal,
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
        isBulkOrder,
        pickup,
        dropoffs,
        totalOrders,
        route,
        walletAmountUsed,
        paymentSource,
        paymentReference,
        riderFee,
        serviceFee,
        taxAmount,
        taxRate,
        taxLabel,
        grandTotal,
        country,
        currency,
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
    bool? isBulkOrder,
    BulkContact? pickup,
    List<BulkContact>? dropoffs,
    int? totalOrders,
    List<BulkOrderRoute>? route,
    double? walletAmountUsed,
    String? paymentSource,
    String? paymentReference,
    double? riderFee,
    double? serviceFee,
    double? taxAmount,
    double? taxRate,
    String? taxLabel,
    double? grandTotal,
    Country? country,
    Currency? currency,
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
      isBulkOrder: isBulkOrder ?? this.isBulkOrder,
      pickup: pickup ?? this.pickup,
      dropoffs: dropoffs ?? this.dropoffs,
      totalOrders: totalOrders ?? this.totalOrders,
      route: route ?? this.route,
      walletAmountUsed: walletAmountUsed ?? this.walletAmountUsed,
      paymentSource: paymentSource ?? this.paymentSource,
      paymentReference: paymentReference ?? this.paymentReference,
      riderFee: riderFee ?? this.riderFee,
      serviceFee: serviceFee ?? this.serviceFee,
      taxAmount: taxAmount ?? this.taxAmount,
      taxRate: taxRate ?? this.taxRate,
      taxLabel: taxLabel ?? this.taxLabel,
      grandTotal: grandTotal ?? this.grandTotal,
      country: country ?? this.country,
      currency: currency ?? this.currency,
    );
  }
}

// --- Response Wrapper (still named DeliveriesResponse as per your original) ---

class DeliveriesResponse extends Equatable {
  final bool success;
  final String message;
  final List<DeliveryModel> data;

  const DeliveriesResponse({
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
