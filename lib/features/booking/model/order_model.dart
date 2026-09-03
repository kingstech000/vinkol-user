// lib/features/booking/model/order_model.dart

class Guest {
  final String email;
  final String firstname;
  final String lastname;
  final String phone;
  final String? role;
  final String? id;

  Guest({
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.phone,
    this.role,
    this.id,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
    };
    if (role != null) data['role'] = role;
    if (id != null) data['_id'] = id;
    return data;
  }

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      email: json['email'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String?,
      id: json['_id'] as String? ?? json['id'] as String?,
    );
  }
}

class OrderModel {
  final String id;
  final String user;
  final LatLngLiteral pickupLocation;
  final LatLngLiteral dropoffLocation;
  final String state;
  final String status;
  final String deliveryType;
  final String vehicleRequest;
  final double amount;
  final String paystackReference;
  final String paymentStatus;
  final String orderOtp;
  final String trackingId;
  final String? externalDeliveryReference;
  final String? deliveryProvider;
  final String? externalDeliveryStatus;
  final String? externalDeliveryPin;
  final int? externalDeliveryFeeId;

  OrderModel({
    required this.id,
    required this.user,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.state,
    required this.status,
    required this.deliveryType,
    required this.vehicleRequest,
    required this.amount,
    required this.paystackReference,
    required this.paymentStatus,
    required this.orderOtp,
    required this.trackingId,
    this.externalDeliveryReference,
    this.deliveryProvider,
    this.externalDeliveryStatus,
    this.externalDeliveryPin,
    this.externalDeliveryFeeId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double parsedAmount;
    var amountValue = json['amount'];
    if (amountValue is num) {
      parsedAmount = amountValue.toDouble();
    } else if (amountValue is String) {
      parsedAmount = double.tryParse(amountValue) ?? 0.0;
    } else {
      parsedAmount = 0.0;
    }

    return OrderModel(
      id: json['_id'] as String,
      user: json['user'] as String,
      pickupLocation: LatLngLiteral.fromJson(
          json['pickupLocation'] as Map<String, dynamic>),
      dropoffLocation: LatLngLiteral.fromJson(
          json['dropoffLocation'] as Map<String, dynamic>),
      state: json['state'] as String,
      status: json['status'] as String,
      deliveryType: json['deliveryType'] as String,
      vehicleRequest: json['vehicleRequest'] as String,
      amount: parsedAmount,
      paystackReference: json['paystackReference'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String,
      orderOtp: json['orderOtp'] as String,
      trackingId: json['trackingId'] as String,
      externalDeliveryReference: json['externalDeliveryReference'] as String?,
      deliveryProvider: json['deliveryProvider'] as String?,
      externalDeliveryStatus: json['externalDeliveryStatus'] as String?,
      externalDeliveryPin:
          json['externalDeliveryPin']?.toString(), // Handle parsing safely
      externalDeliveryFeeId: json['externalDeliveryFeeId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'pickupLocation': pickupLocation.toJson(),
      'dropoffLocation': dropoffLocation.toJson(),
      'state': state,
      'status': status,
      'deliveryType': deliveryType,
      'vehicleRequest': vehicleRequest,
      'amount': amount,
      'paystackReference': paystackReference,
      'paymentStatus': paymentStatus,
      'orderOtp': orderOtp,
      'trackingId': trackingId,
      'externalDeliveryReference': externalDeliveryReference,
      'deliveryProvider': deliveryProvider,
      'externalDeliveryStatus': externalDeliveryStatus,
      'externalDeliveryPin': externalDeliveryPin,
      'externalDeliveryFeeId': externalDeliveryFeeId,
    };
  }

  OrderModel copyWith({
    String? id,
    String? user,
    LatLngLiteral? pickupLocation,
    LatLngLiteral? dropoffLocation,
    String? state,
    String? status,
    String? deliveryType,
    String? vehicleRequest,
    double? amount,
    String? paystackReference,
    String? paymentStatus,
    String? orderOtp,
    String? trackingId,
    String? externalDeliveryReference,
    String? deliveryProvider,
    String? externalDeliveryStatus,
    String? externalDeliveryPin,
    int? externalDeliveryFeeId,
  }) {
    return OrderModel(
      id: id ?? this.id,
      user: user ?? this.user,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      state: state ?? this.state,
      status: status ?? this.status,
      deliveryType: deliveryType ?? this.deliveryType,
      vehicleRequest: vehicleRequest ?? this.vehicleRequest,
      amount: amount ?? this.amount,
      paystackReference: paystackReference ?? this.paystackReference,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderOtp: orderOtp ?? this.orderOtp,
      trackingId: trackingId ?? this.trackingId,
      externalDeliveryReference:
          externalDeliveryReference ?? this.externalDeliveryReference,
      deliveryProvider: deliveryProvider ?? this.deliveryProvider,
      externalDeliveryStatus:
          externalDeliveryStatus ?? this.externalDeliveryStatus,
      externalDeliveryPin: externalDeliveryPin ?? this.externalDeliveryPin,
      externalDeliveryFeeId:
          externalDeliveryFeeId ?? this.externalDeliveryFeeId,
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, status: $status, pickup: ${pickupLocation.lat},${pickupLocation.lng}, dropoff: ${dropoffLocation.lat},${dropoffLocation.lng}, provider: $deliveryProvider)';
  }
}

// --- Associated Models (unchanged in this specific request, but included for context) ---

class ApiResponse {
  final bool success;
  final String message;
  final QuoteResponseModel data;

  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: QuoteResponseModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class QuoteResponseModel {
  final String state;
  final String orderType;
  final LatLngLiteral dropoffLocation;
  final LatLngLiteral pickupLocation;
  final String deliveryType;
  final String vehicleRequest;
  final double price;
  final double? discountedPrice; // Optional field
  final int? id; // For External Chowdeck Quote ID
  final double? vinkolAmount; // For Chowdeck price
  final bool isAvailable;
  final String? unavailableMessage;

  QuoteResponseModel({
    required this.state,
    required this.orderType,
    required this.dropoffLocation,
    required this.pickupLocation,
    required this.deliveryType,
    required this.vehicleRequest,
    required this.price,
    this.discountedPrice, // Optional parameter
    this.id,
    this.vinkolAmount,
    this.isAvailable = true,
    this.unavailableMessage,
  });

  factory QuoteResponseModel.fromJson(Map<String, dynamic> json) {
    double parsedPrice;
    var priceValue = json['price'];
    if (priceValue is num) {
      parsedPrice = priceValue.toDouble();
    } else if (priceValue is String) {
      parsedPrice = double.tryParse(priceValue) ?? 0.0;
    } else {
      parsedPrice = 0.0;
    }

    // Parse discountedPrice if present
    double? parsedDiscountedPrice;
    var discountedPriceValue = json['discountedPrice'];
    if (discountedPriceValue != null) {
      if (discountedPriceValue is num) {
        parsedDiscountedPrice = discountedPriceValue.toDouble();
      } else if (discountedPriceValue is String) {
        parsedDiscountedPrice = double.tryParse(discountedPriceValue);
      }
    }

    return QuoteResponseModel(
      state: json['state'] as String,
      orderType: json['orderType'] as String,
      dropoffLocation: LatLngLiteral.fromJson(
          json['dropoffLocation'] as Map<String, dynamic>),
      pickupLocation: LatLngLiteral.fromJson(
          json['pickupLocation'] as Map<String, dynamic>),
      deliveryType: json['deliveryType'] as String,
      vehicleRequest: json['vehicleRequest'] as String,
      price: parsedPrice,
      discountedPrice: parsedDiscountedPrice,
      id: json['id'] as int?,
      vinkolAmount: json['vinkol_amount'] != null
          ? (json['vinkol_amount'] as num).toDouble()
          : null,
      isAvailable: json['isAvailable'] as bool? ?? true,
      unavailableMessage: json['unavailableMessage'] as String?,
    );
  }

  QuoteResponseModel copyWith({
    String? state,
    String? orderType,
    LatLngLiteral? dropoffLocation,
    LatLngLiteral? pickupLocation,
    String? deliveryType,
    String? vehicleRequest,
    double? price,
    double? discountedPrice,
    int? id,
    double? vinkolAmount,
    bool? isAvailable,
    String? unavailableMessage,
  }) {
    return QuoteResponseModel(
      state: state ?? this.state,
      orderType: orderType ?? this.orderType,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryType: deliveryType ?? this.deliveryType,
      vehicleRequest: vehicleRequest ?? this.vehicleRequest,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      id: id ?? this.id,
      vinkolAmount: vinkolAmount ?? this.vinkolAmount,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailableMessage: unavailableMessage ?? this.unavailableMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'orderType': orderType,
      'dropoffLocation': dropoffLocation.toJson(),
      'pickupLocation': pickupLocation.toJson(),
      'deliveryType': deliveryType,
      'vehicleRequest': vehicleRequest,
      'price': price,
      if (discountedPrice != null)
        'discountedPrice': discountedPrice, // Only include if not null
      if (id != null) 'id': id,
      if (vinkolAmount != null) 'vinkol_amount': vinkolAmount,
      'isAvailable': isAvailable,
      if (unavailableMessage != null) 'unavailableMessage': unavailableMessage,
    };
  }
}

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

class QuoteItem {
  final String serviceType;
  final String estimatedTime;
  final double price;
  final String vehicleType;

  QuoteItem({
    required this.serviceType,
    required this.estimatedTime,
    required this.price,
    required this.vehicleType,
  });

  factory QuoteItem.fromQuoteResponseModel(QuoteResponseModel model) {
    return QuoteItem(
      serviceType: model.deliveryType,
      estimatedTime: "30-60 min",
      price: model.price,
      vehicleType: model.vehicleRequest,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      'estimatedTime': estimatedTime,
      'price': price,
      'vehicleType': vehicleType,
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

class BulkRoute {
  final RouteEndpoint from;
  final RouteEndpoint to;
  final double price;
  final double distance;
  final String? id;

  BulkRoute({
    required this.from,
    required this.to,
    required this.price,
    required this.distance,
    this.id,
  });

  factory BulkRoute.fromJson(Map<String, dynamic> json) {
    return BulkRoute(
      from: RouteEndpoint.fromJson(json['from'] as Map<String, dynamic>),
      to: RouteEndpoint.fromJson(json['to'] as Map<String, dynamic>),
      price: (json['price'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      id: json['_id'] as String? ?? json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'from': from.toJson(),
      'to': to.toJson(),
      'price': price,
      'distance': distance,
    };
    if (id != null) data['_id'] = id;
    return data;
  }
}

class BulkQuoteResponse {
  final String quote;
  final double totalAmount;
  final double totalDistance;
  final List<BulkRoute> route;
  final int stops;

  BulkQuoteResponse({
    required this.quote,
    required this.totalAmount,
    required this.totalDistance,
    required this.route,
    required this.stops,
  });

  factory BulkQuoteResponse.fromJson(Map<String, dynamic> json) {
    return BulkQuoteResponse(
      quote: json['quote'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalDistance: (json['totalDistance'] as num).toDouble(),
      route: (json['route'] as List<dynamic>)
          .map((e) => BulkRoute.fromJson(e as Map<String, dynamic>))
          .toList(),
      stops: json['stops'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quote': quote,
      'totalAmount': totalAmount,
      'totalDistance': totalDistance,
      'route': route.map((e) => e.toJson()).toList(),
      'stops': stops,
    };
  }
}

class MultiOrderItem {
  final String? id;
  final LatLngWithAddress pickupLocation;
  final LatLngWithAddress dropoffLocation;
  final String? pickupContactName;
  final String? pickupContactPhone;
  final String? receiverContactName;
  final String? receiverContactPhone;
  final String? state;
  final String? vehicleRequest;
  final String? note;
  final String? description;
  final double deliveryFee;
  final double distance;

  MultiOrderItem({
    this.id,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.pickupContactName,
    this.pickupContactPhone,
    this.receiverContactName,
    this.receiverContactPhone,
    this.state,
    this.vehicleRequest,
    this.note,
    this.description,
    required this.deliveryFee,
    required this.distance,
  });

  factory MultiOrderItem.fromJson(Map<String, dynamic> json) {
    final pickupContact = json['pickupContact'] as Map<String, dynamic>?;
    final receiverContact = json['receiverContact'] as Map<String, dynamic>?;
    return MultiOrderItem(
      id: json['_id'] as String?,
      pickupLocation:
          LatLngWithAddress.fromJson(json['pickupLocation'] as Map<String, dynamic>),
      dropoffLocation:
          LatLngWithAddress.fromJson(json['dropoffLocation'] as Map<String, dynamic>),
      pickupContactName: pickupContact?['name'] as String?,
      pickupContactPhone: pickupContact?['phone'] as String?,
      receiverContactName: receiverContact?['name'] as String?,
      receiverContactPhone: receiverContact?['phone'] as String?,
      state: json['state'] as String?,
      vehicleRequest: json['vehicleRequest'] as String?,
      note: json['note'] as String?,
      description: json['description'] as String?,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MultiOrderQuoteResponse {
  final String? user;
  final Guest? guest;
  final double totalAmount;
  final String quote;
  final int totalOrders;
  final List<MultiOrderItem> orders;

  MultiOrderQuoteResponse({
    this.user,
    this.guest,
    required this.totalAmount,
    required this.quote,
    required this.totalOrders,
    this.orders = const [],
  });

  factory MultiOrderQuoteResponse.fromJson(Map<String, dynamic> json) {
    // Parse orders from quoteDetails.orders if present
    List<MultiOrderItem> parsedOrders = [];
    final quoteDetails = json['quoteDetails'] as Map<String, dynamic>?;
    if (quoteDetails != null && quoteDetails['orders'] is List) {
      parsedOrders = (quoteDetails['orders'] as List)
          .map((e) => MultiOrderItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return MultiOrderQuoteResponse(
      user: json['user'] as String?,
      guest: json['guest'] != null
          ? Guest.fromJson(json['guest'] as Map<String, dynamic>)
          : null,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      quote: json['quote'] as String,
      totalOrders: json['totalOrders'] as int,
      orders: parsedOrders,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'totalAmount': totalAmount,
      'quote': quote,
      'totalOrders': totalOrders,
    };
    if (user != null) data['user'] = user;
    if (guest != null) data['guest'] = guest!.toJson();
    return data;
  }
}
