// lib/features/booking/model/order_model.dart
import 'package:starter_codes/features/booking/model/order_model.dart';

// What a single-delivery quote comes back as.

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
