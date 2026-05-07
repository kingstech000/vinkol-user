import 'package:starter_codes/models/location_model.dart';

class CreateOrderRequest {
  final LocationModel pickupLocation;
  final LocationModel dropOffLocation;
  final String packageType;
  final String packageName;
  final String priorityType;
  final String vehicleType;
  final String estimatedDeliveryTime;
  final double price;
  final String pickupDate;
  final String pickupTime;
  final String note;
  final String state;
  final String? paymentSource;
  final String? deliveryProvider;
  final int? externalDeliveryFeeId;
  final String? description;
  final String? recipientName;
  final String? recipientPhone;

  CreateOrderRequest({
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.packageType,
    required this.packageName,
    required this.priorityType,
    required this.vehicleType,
    required this.estimatedDeliveryTime,
    required this.price,
    required this.pickupDate,
    required this.pickupTime,
    required this.note,
    required this.state,
    this.paymentSource,
    this.deliveryProvider,
    this.externalDeliveryFeeId,
    this.description,
    this.recipientName,
    this.recipientPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      "date": pickupDate,
      "time": pickupTime,
      'pickupLocation': pickupLocation.formattedAddress,
      'dropoffLocation': dropOffLocation.formattedAddress,
      'deliveryType': priorityType,
      'vehicleRequest': vehicleType,
      "orderType": "Delivery",
      'state': state,
      'deliveryFee': price,
      'itemType': packageName,
      // 'packageName': packageName,
      if (paymentSource != null) 'paymentSource': paymentSource,
      if (deliveryProvider != null) 'deliveryProvider': deliveryProvider,
      if (externalDeliveryFeeId != null)
        'externalDeliveryFeeId': externalDeliveryFeeId,
      if (description != null) 'description': description,
      if (note.isNotEmpty) 'note': note,
      if (recipientName != null && recipientPhone != null)
        "receiverContact": {"name": recipientName, "phone": recipientPhone}
    };
  }

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) {
    return CreateOrderRequest(
      state: json['state'] as String,
      pickupLocation: LocationModel.fromJson(
          json['pickupLocation'] as Map<String, dynamic>),
      dropOffLocation: LocationModel.fromJson(
          json['dropOffLocation'] as Map<String, dynamic>),
      packageType: json['packageType'] as String,
      packageName: json['packageName'] as String,
      priorityType: json['priorityType'] as String,
      vehicleType: json['vehicleType'] as String,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] as String,
      price: (json['price'] as num).toDouble(),
      pickupDate: json['pickupDate'] as String,
      pickupTime: json['pickupTime'] as String,
      note: json['note'] as String,
      paymentSource: json['paymentSource'] as String?,
      deliveryProvider: json['deliveryProvider'] as String?,
      externalDeliveryFeeId: json['externalDeliveryFeeId'] as int?,
      description: json['description'] as String?,
      recipientName: json['recipientName'] as String?,
      recipientPhone: json['recipientPhone'] as String?,
    );
  }

  CreateOrderRequest copyWith({
    LocationModel? pickupLocation,
    LocationModel? dropOffLocation,
    String? packageType,
    String? packageName,
    String? priorityType,
    String? vehicleType,
    String? estimatedDeliveryTime,
    double? price,
    String? pickupDate,
    String? pickupTime,
    String? note,
    String? paystackReference,
    String? state,
    String? paymentSource,
    String? deliveryProvider,
    int? externalDeliveryFeeId,
    String? description,
    String? recipientName,
    String? recipientPhone,
  }) {
    return CreateOrderRequest(
      state: state ?? this.state,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropOffLocation: dropOffLocation ?? this.dropOffLocation,
      packageType: packageType ?? this.packageType,
      packageName: packageName ?? this.packageName,
      priorityType: priorityType ?? this.priorityType,
      vehicleType: vehicleType ?? this.vehicleType,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      price: price ?? this.price,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTime: pickupTime ?? this.pickupTime,
      note: note ?? this.note,
      paymentSource: paymentSource ?? this.paymentSource,
      deliveryProvider: deliveryProvider ?? this.deliveryProvider,
      externalDeliveryFeeId:
          externalDeliveryFeeId ?? this.externalDeliveryFeeId,
      description: description ?? this.description,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
    );
  }
}

// ---  GetQuoteRequest ---
class GetQuoteRequest {
  final String state;
  final String orderType;
  final LocationData dropoffLocation;
  final LocationData pickupLocation;
  final String vehicleRequest;
  final String? userId;

  final String? note;
  final String? pickupTime;
  final String? pickupDate;
  final String? name;
  GetQuoteRequest({
    required this.state,
    this.name,
    this.note,
    this.pickupDate,
    this.pickupTime,
    required this.orderType,
    required this.dropoffLocation,
    required this.pickupLocation,
    required this.userId,
    // required this.deliveryType,
    required this.vehicleRequest,
  });

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'orderType': orderType,
      'dropoffLocation': dropoffLocation.toJson(),
      'pickupLocation': pickupLocation.toJson(),
      'vehicleRequest': vehicleRequest,
      'userId': userId,
    };
  }

  factory GetQuoteRequest.fromJson(Map<String, dynamic> json) {
    return GetQuoteRequest(
      state: json['state'] as String,
      orderType: json['orderType'] as String,
      dropoffLocation: LocationData.fromJson(
          json['dropoffLocation'] as Map<String, dynamic>),
      pickupLocation:
          LocationData.fromJson(json['pickupLocation'] as Map<String, dynamic>),
      vehicleRequest: json['vehicleRequest'] as String,
      userId: json['userId'] as String,
    );
  }

  GetQuoteRequest copyWith({
    String? state,
    String? orderType,
    LocationData? dropoffLocation,
    LocationData? pickupLocation,
    String? deliveryType,
    String? vehicleRequest,
    String? userId,
  }) {
    return GetQuoteRequest(
      state: state ?? this.state,
      orderType: orderType ?? this.orderType,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      vehicleRequest: vehicleRequest ?? this.vehicleRequest,
      userId: userId ?? this.userId,
    );
  }
}

class LocationData {
  final String lat;
  final String lng;

  LocationData({
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      lat: json['lat'] as String,
      lng: json['lng'] as String,
    );
  }

  LocationData copyWith({
    String? lat,
    String? lng,
  }) {
    return LocationData(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
