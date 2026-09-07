// lib/features/booking/model/order_model.dart
import 'package:starter_codes/features/booking/model/order_model.dart';

// What a multi-drop quote comes back as.

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
      pickupLocation: LatLngWithAddress.fromJson(
          json['pickupLocation'] as Map<String, dynamic>),
      dropoffLocation: LatLngWithAddress.fromJson(
          json['dropoffLocation'] as Map<String, dynamic>),
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
