// lib/features/booking/model/order_model.dart


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

  OrderModel({
    required this.id,
    required this.user,
    // CHANGED: type is LatLngLiteral
    required this.pickupLocation,
    // CHANGED: type is LatLngLiteral
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
      // CHANGED: Parse pickupLocation as LatLngLiteral
      pickupLocation: LatLngLiteral.fromJson(json['pickupLocation'] as Map<String, dynamic>),
      // CHANGED: Parse dropoffLocation as LatLngLiteral
      dropoffLocation: LatLngLiteral.fromJson(json['dropoffLocation'] as Map<String, dynamic>),
      state: json['state'] as String,
      status: json['status'] as String,
      deliveryType: json['deliveryType'] as String,
      vehicleRequest: json['vehicleRequest'] as String,
      amount: parsedAmount,
      paystackReference: json['paystackReference'] as String,
      paymentStatus: json['paymentStatus'] as String,
      orderOtp: json['orderOtp'] as String,
      trackingId: json['trackingId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      // CHANGED: Convert pickupLocation to JSON
      'pickupLocation': pickupLocation.toJson(),
      // CHANGED: Convert dropoffLocation to JSON
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
    };
  }

  OrderModel copyWith({
    String? id,
    String? user,
    // CHANGED: type is LatLngLiteral
    LatLngLiteral? pickupLocation,
    // CHANGED: type is LatLngLiteral
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
  }) {
    return OrderModel(
      id: id ?? this.id,
      user: user ?? this.user,
      // CHANGED: copyWith uses LatLngLiteral
      pickupLocation: pickupLocation ?? this.pickupLocation,
      // CHANGED: copyWith uses LatLngLiteral
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
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, status: $status, pickup: ${pickupLocation.lat},${pickupLocation.lng}, dropoff: ${dropoffLocation.lat},${dropoffLocation.lng})';
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

  QuoteResponseModel({
    required this.state,
    required this.orderType,
    required this.dropoffLocation,
    required this.pickupLocation,
    required this.deliveryType,
    required this.vehicleRequest,
    required this.price,
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

    return QuoteResponseModel(
      state: json['state'] as String,
      orderType: json['orderType'] as String,
      dropoffLocation: LatLngLiteral.fromJson(json['dropoffLocation'] as Map<String, dynamic>),
      pickupLocation: LatLngLiteral.fromJson(json['pickupLocation'] as Map<String, dynamic>),
      deliveryType: json['deliveryType'] as String,
      vehicleRequest: json['vehicleRequest'] as String,
      price: parsedPrice,
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