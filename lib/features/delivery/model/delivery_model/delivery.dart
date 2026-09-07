import 'package:equatable/equatable.dart';
// import 'package:intl/intl.dart'; // Uncomment if you use DateFormat for date/time parsing

// --- Bulk Order Sub-Models ---
import 'package:starter_codes/features/delivery/model/delivery_model.dart';

// A delivery as the API returns it, and a page of them.

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
        riderFee: (json['riderFee'] as num?)?.toDouble());
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
        isBulkOrder,
        pickup,
        dropoffs,
        totalOrders,
        route,
        walletAmountUsed,
        paymentSource,
        paymentReference,
        riderFee,
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
