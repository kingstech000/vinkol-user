// lib/features/booking/model/order_model.dart
import 'package:starter_codes/features/booking/model/order_model.dart';

// A placed order and the envelope it arrives in.

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
