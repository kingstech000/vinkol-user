import 'package:starter_codes/models/location_model.dart';

class CreateOrderRequest {

  final LocationModel pickupLocation; // Changed from String to LocationModel
  final LocationModel dropOffLocation; // Changed from String to LocationModel
  final String packageType; // Added based on usage in MapWithQuotesScreen
  final String packageName; // Added based on usage in MapWithQuotesScreen
  final String priorityType; // Mapped from QuoteItem's serviceType
  final String vehicleType; // Mapped from QuoteItem's vehicleType
  final String estimatedDeliveryTime; // Mapped from QuoteItem's estimatedTime
  final double price; // Mapped from QuoteItem's price
  final String pickupDate; // Added based on usage in MapWithQuotesScreen
  final String pickupTime; // Added based on usage in MapWithQuotesScreen
  final String note; // Added based on usage in MapWithQuotesScreen
  final String state;
final String paystackReference;
  CreateOrderRequest({
    required this.paystackReference, // Uncomment if needed for initial request
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
    required this.state
  });

  Map<String, dynamic> toJson() {
    return { 
    "date":pickupDate,
    "time" :pickupTime,
      'pickupLocation':
          pickupLocation.formattedAddress ,//!.toJson(), // Convert LocationModel to JSON
      'dropoffLocation':
          dropOffLocation.formattedAddress  ,//.toJson(), // Convert LocationModel to JSON
      'deliveryType': priorityType,
      'vehicleRequest': vehicleType,
     "orderType": "Delivery",
      'state':state,
      'deliveryFee':price,
      'paystackReference':paystackReference,
    };
  }

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) {
    return CreateOrderRequest(
      state: json['state'] as String,
       paystackReference: json['paystackReference'] as String, // Uncomment if needed for initial request
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
    );
  }

  CreateOrderRequest copyWith({
    // String? paystackReference, // Uncomment if needed for initial request
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
    String? state
  }) {
    return CreateOrderRequest(
      state: state?? this.state,
       paystackReference: paystackReference ?? this.paystackReference, 
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
    );
  }
}

// ---  GetQuoteRequest ---
class GetQuoteRequest {
  final String state;
  final String orderType;
  final LocationData dropoffLocation;
  final LocationData pickupLocation;
  // final String deliveryType; // "regular", "express"
  final String vehicleRequest; // "truck", "car", "bike"
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
      // 'deliveryType': deliveryType,
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
      // deliveryType: json['deliveryType'] as String,
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
      // deliveryType: deliveryType ?? this.deliveryType,
      vehicleRequest: vehicleRequest ?? this.vehicleRequest,
      userId: userId ?? this.userId,
    );
  }
}

// Nested model for Location Data (assuming it's still needed by GetQuoteRequest)
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
