// lib/features/booking/model/order_model.dart
import 'package:starter_codes/features/booking/model/order_model.dart';

// What a batch quote comes back as.

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
