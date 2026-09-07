import 'package:starter_codes/core/money/money.dart';

class OrderInitiationResponse {
  final Order? order;
  final List<String>? orderIds;
  final String? authorizationUrl;
  final String? reference;

  OrderInitiationResponse({
    this.order,
    this.orderIds,
    this.authorizationUrl,
    this.reference,
  });

  factory OrderInitiationResponse.fromJson(Map<String, dynamic> json) {
    return OrderInitiationResponse(
      order: json['order'] != null ? Order.fromJson(json['order']) : null,
      orderIds:
          json['orders'] != null ? List<String>.from(json['orders']) : null,
      authorizationUrl: json['authorization_url'],
      reference: json['reference'],
    );
  }

  Map<String, dynamic> toJson() => {
        'order': order?.toJson(),
        'orders': orderIds,
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
  final double? amount;
  final double deliveryFee; // Changed to handle null
  final String? paystackReference;
  final String paymentStatus;
  final List<dynamic> products;
  final String? store;
  final String id;
  final String orderOtp;
  final String trackingId;
  final double totalAmount; // Changed to handle null

  /// What the customer is actually charged: fare + service fee + tax. Null when
  /// the server has not itemised the bill, in which case [totalAmount] stands.
  final double? grandTotal;
  final double? serviceFee;
  final double? taxAmount;
  final double? taxRate;
  final String? taxLabel;

  /// The market this order belongs to, decided by the server from the pickup
  /// coordinates. Absent on records written before the Canada expansion, all of
  /// which are Nigerian.
  final Country country;
  final Currency currency;

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
    this.grandTotal,
    this.serviceFee,
    this.taxAmount,
    this.taxRate,
    this.taxLabel,
    this.country = Country.ng,
    this.currency = Currency.ngn,
  });

  /// What to charge and display, per the expansion guide.
  Money get amountDue => Money(grandTotal ?? totalAmount, currency);

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
      amount: Money.parseAmount(json['amount']),
      deliveryFee: Money.parseAmount(json['deliveryFee']) ?? 0,
      paystackReference: json['paystackReference'] as String?,
      paymentStatus: json['paymentStatus'] as String,
      products: json['products'] as List<dynamic>? ?? [],
      store: json['store'] as String?,
      id: json['_id'] ?? json['id'],
      orderOtp: json['orderOtp'].toString(),
      trackingId: json['trackingId'] as String,
      totalAmount: Money.parseAmount(json['totalAmount']) ?? 0,
      externalDeliveryFeeId: json['externalDeliveryFeeId'] as int?,
      deliveryProvider: json['deliveryProvider'] as String?,
      externalDeliveryId: json['externalDeliveryId'] as int?,
      externalDeliveryReference: json['externalDeliveryReference'] as String?,
      externalDeliveryStatus: json['externalDeliveryStatus'] as String?,
      externalDeliveryPin: json['externalDeliveryPin'] as String?,
      paymentSource: json['paymentSource'] as String?,
      grandTotal: Money.parseAmount(json['grandTotal']),
      serviceFee: Money.parseAmount(json['serviceFee']),
      taxAmount: Money.parseAmount(json['taxAmount']),
      taxRate: Money.parseAmount(json['taxRate']),
      taxLabel: json['taxLabel'] as String?,
      country: Country.fromCode(json['country'] as String?),
      currency: Currency.fromCode(json['currency'] as String?),
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
        if (grandTotal != null) 'grandTotal': grandTotal,
        if (serviceFee != null) 'serviceFee': serviceFee,
        if (taxAmount != null) 'taxAmount': taxAmount,
        if (taxRate != null) 'taxRate': taxRate,
        if (taxLabel != null) 'taxLabel': taxLabel,
        'country': country.code,
        'currency': currency.code,
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
