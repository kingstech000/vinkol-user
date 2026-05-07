class OrderInitiationResponse {
  final Order order;
  final String? authorizationUrl;
  final String? reference;

  OrderInitiationResponse({
    required this.order,
    this.authorizationUrl,
    this.reference,
  });

  factory OrderInitiationResponse.fromJson(Map<String, dynamic> json) {
    return OrderInitiationResponse(
      order: Order.fromJson(json['order']),
      authorizationUrl: json['authorization_url'],
      reference: json['reference'],
    );
  }

  Map<String, dynamic> toJson() => {
        'order': order.toJson(),
        'authorization_url': authorizationUrl,
        'reference': reference,
      };
}

class Order {
  final String user;
  final String pickupLocation;
  final Dispute dispute;
  final String dropoffLocation;
  final String state;
  final String status;
  final String? date;
  final String? time;
  final String deliveryType;
  final String? vehicleRequest;
  final String orderType;
  final String note;
  final String description;
  final int? amount;
  final int deliveryFee; // Changed to handle null
  final String? paystackReference;
  final String paymentStatus;
  final List<dynamic> products;
  final String? store;
  final String id;
  final String orderOtp;
  final String trackingId;
  final int totalAmount; // Changed to handle null

  final int? externalDeliveryFeeId;
  final String? deliveryProvider;
  final int? externalDeliveryId;
  final String? externalDeliveryReference;
  final String? externalDeliveryStatus;
  final String? externalDeliveryPin;
  final String? paymentSource;

  Order({
    required this.user,
    required this.pickupLocation,
    required this.dispute,
    required this.dropoffLocation,
    required this.state,
    required this.status,
    this.date,
    this.time,
    required this.deliveryType,
    this.vehicleRequest,
    required this.orderType,
    required this.note,
    required this.description,
    this.amount,
    required this.deliveryFee,
    this.paystackReference,
    required this.paymentStatus,
    required this.products,
    this.store,
    required this.id,
    required this.orderOtp,
    required this.trackingId,
    required this.totalAmount,
    this.externalDeliveryFeeId,
    this.deliveryProvider,
    this.externalDeliveryId,
    this.externalDeliveryReference,
    this.externalDeliveryStatus,
    this.externalDeliveryPin,
    this.paymentSource,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      user: json['user'] as String,
      pickupLocation: json['pickupLocation'] as String,
      dispute: Dispute.fromJson(json['dispute'] as Map<String, dynamic>),
      dropoffLocation: json['dropoffLocation'] as String,
      state: json['state'] as String,
      status: json['status'] as String,
      date: json['date'] as String?,
      time: json['time'] as String?,
      deliveryType: json['deliveryType'] as String,
      vehicleRequest: json['vehicleRequest'] as String?,
      orderType: json['orderType'] as String,
      note: json['note'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt(),
      deliveryFee: (json['deliveryFee'] as num?)?.toInt() ??
          0, // Fixed: Handle null with default
      paystackReference: json['paystackReference'] as String?,
      paymentStatus: json['paymentStatus'] as String,
      products: json['products'] as List<dynamic>? ?? [],
      store: json['store'] as String?,
      id: json['_id'] ?? json['id'],
      orderOtp: json['orderOtp'].toString(),
      trackingId: json['trackingId'] as String,
      totalAmount: (json['totalAmount'] as num?)?.toInt() ??
          0, // Fixed: Handle null with default
      externalDeliveryFeeId: json['externalDeliveryFeeId'] as int?,
      deliveryProvider: json['deliveryProvider'] as String?,
      externalDeliveryId: json['externalDeliveryId'] as int?,
      externalDeliveryReference: json['externalDeliveryReference'] as String?,
      externalDeliveryStatus: json['externalDeliveryStatus'] as String?,
      externalDeliveryPin: json['externalDeliveryPin'] as String?,
      paymentSource: json['paymentSource'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user,
        'pickupLocation': pickupLocation,
        'dispute': dispute.toJson(),
        'dropoffLocation': dropoffLocation,
        'state': state,
        'status': status,
        if (date != null) 'date': date,
        if (time != null) 'time': time,
        'deliveryType': deliveryType,
        if (vehicleRequest != null) 'vehicleRequest': vehicleRequest,
        'orderType': orderType,
        'note': note,
        'description': description,
        if (amount != null) 'amount': amount,
        'deliveryFee': deliveryFee,
        'paystackReference': paystackReference,
        'paymentStatus': paymentStatus,
        'products': products,
        if (store != null) 'store': store,
        '_id': id,
        'orderOtp': orderOtp,
        'trackingId': trackingId,
        'totalAmount': totalAmount,
        if (externalDeliveryFeeId != null)
          'externalDeliveryFeeId': externalDeliveryFeeId,
        if (deliveryProvider != null) 'deliveryProvider': deliveryProvider,
        if (externalDeliveryId != null)
          'externalDeliveryId': externalDeliveryId,
        if (externalDeliveryReference != null)
          'externalDeliveryReference': externalDeliveryReference,
        if (externalDeliveryStatus != null)
          'externalDeliveryStatus': externalDeliveryStatus,
        if (externalDeliveryPin != null)
          'externalDeliveryPin': externalDeliveryPin,
        if (paymentSource != null) 'paymentSource': paymentSource,
      };
}

class Dispute {
  final bool status;

  Dispute({required this.status});

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(status: json['status']);
  }

  Map<String, dynamic> toJson() => {'status': status};
}

class Product {
  final String product;
  final int quantity;
  final String id;

  Product({
    required this.product,
    required this.quantity,
    required this.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      product: json['product'],
      quantity: json['quantity'],
      id: json['_id'] ?? json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'product': product,
        'quantity': quantity,
        '_id': id,
      };
}
