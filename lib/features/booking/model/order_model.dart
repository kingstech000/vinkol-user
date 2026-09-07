// lib/features/booking/model/order_model.dart
import 'package:starter_codes/core/money/money.dart';

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

  /// The market this order belongs to, decided by the server from the pickup
  /// coordinates. Absent on records written before the Canada expansion, all of
  /// which are Nigerian.
  final Country country;
  final Currency currency;

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
    this.country = Country.ng,
    this.currency = Currency.ngn,
  });

  Money get amountMoney => Money(amount, currency);

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
      country: Country.fromCode(json['country'] as String?),
      currency: Currency.fromCode(json['currency'] as String?),
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
      'country': country.code,
      'currency': currency.code,
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
    Country? country,
    Currency? currency,
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
      country: country ?? this.country,
      currency: currency ?? this.currency,
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

class QuoteResponseModel {
  final String state;
  final String orderType;
  final LatLngLiteral dropoffLocation;
  final LatLngLiteral pickupLocation;
  final String deliveryType;
  final String vehicleRequest;
  final double price;
  final double? discountedPrice; // Optional field
  final double? vinkolAmount; // For Chowdeck price
  final bool isAvailable;
  final String? unavailableMessage;

  /// The server-issued quote id. Sending this on order creation is the only way
  /// to get a Canadian price; a raw `deliveryFee` always prices as Nigerian.
  ///
  /// Single-use, and expires 15 minutes after it was issued.
  final String? quoteId;

  /// Chowdeck's own fee id, sent back as `externalDeliveryFeeId` on creation.
  /// Unrelated to [quoteId] despite both once being called "the quote id".
  final int? externalDeliveryFeeId;

  /// Processing fee. Zero on Nigerian plain deliveries.
  final double? serviceFee;

  /// Tax resolved from the delivery's province. Zero in Nigeria.
  final double? taxAmount;

  /// The rate the tax was computed at, e.g. `0.13`.
  final double? taxRate;

  /// What to call the tax on the receipt, e.g. `HST` or `GST + QST`. Not always
  /// a single tax, so it cannot be derived from the country.
  final String? taxLabel;

  /// What the customer is actually charged: fare + service fee + tax.
  /// In Nigeria this equals [price].
  final double? grandTotal;

  final Currency currency;

  /// The market the server resolved from the pickup coordinates. The client
  /// never chooses this — it reads it off the quote.
  final Country country;

  /// When the server stops accepting this quote. It issues a 15-minute window
  /// and returns the exact instant, so the expiry never has to be guessed.
  final DateTime? expiresAt;

  QuoteResponseModel({
    required this.state,
    required this.orderType,
    required this.dropoffLocation,
    required this.pickupLocation,
    required this.deliveryType,
    required this.vehicleRequest,
    required this.price,
    this.discountedPrice, // Optional parameter
    this.externalDeliveryFeeId,
    this.vinkolAmount,
    this.isAvailable = true,
    this.unavailableMessage,
    this.quoteId,
    this.serviceFee,
    this.taxAmount,
    this.taxRate,
    this.taxLabel,
    this.grandTotal,
    this.currency = Currency.ngn,
    this.country = Country.ng,
    this.expiresAt,
  });

  /// What to charge and display. Falls back to the fare when the server has not
  /// itemised the bill, which keeps Nigerian plain deliveries rendering as before.
  Money get amountDue =>
      Money(grandTotal ?? discountedPrice ?? price, currency);

  Money get fare => Money(discountedPrice ?? price, currency);

  Money? get serviceFeeMoney =>
      serviceFee == null ? null : Money(serviceFee!, currency);

  Money? get taxMoney => taxAmount == null ? null : Money(taxAmount!, currency);

  /// Whether the bill has lines worth showing beyond the fare itself.
  bool get hasItemisedCharges => (serviceFee ?? 0) > 0 || (taxAmount ?? 0) > 0;

  /// Whether this quote can still be used to create an order.
  bool get isExpired =>
      expiresAt != null && !DateTime.now().toUtc().isBefore(expiresAt!.toUtc());


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
      externalDeliveryFeeId: json['id'] as int?,
      vinkolAmount: json['vinkol_amount'] != null
          ? (json['vinkol_amount'] as num).toDouble()
          : null,
      isAvailable: json['isAvailable'] as bool? ?? true,
      unavailableMessage: json['unavailableMessage'] as String?,
      quoteId: json['quoteId']?.toString(),
      serviceFee: Money.parseAmount(json['serviceFee']),
      taxAmount: Money.parseAmount(json['taxAmount']),
      taxRate: Money.parseAmount(json['taxRate']),
      taxLabel: json['taxLabel'] as String?,
      grandTotal: Money.parseAmount(json['grandTotal']),
      currency: Currency.fromCode(json['currency'] as String?),
      country: Country.fromCode(json['country'] as String?),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.tryParse(json['expiresAt'].toString()),
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
    int? externalDeliveryFeeId,
    double? vinkolAmount,
    bool? isAvailable,
    String? unavailableMessage,
    String? quoteId,
    double? serviceFee,
    double? taxAmount,
    double? taxRate,
    String? taxLabel,
    double? grandTotal,
    Currency? currency,
    Country? country,
    DateTime? expiresAt,
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
      externalDeliveryFeeId:
          externalDeliveryFeeId ?? this.externalDeliveryFeeId,
      vinkolAmount: vinkolAmount ?? this.vinkolAmount,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailableMessage: unavailableMessage ?? this.unavailableMessage,
      quoteId: quoteId ?? this.quoteId,
      serviceFee: serviceFee ?? this.serviceFee,
      taxAmount: taxAmount ?? this.taxAmount,
      taxRate: taxRate ?? this.taxRate,
      taxLabel: taxLabel ?? this.taxLabel,
      grandTotal: grandTotal ?? this.grandTotal,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      expiresAt: expiresAt ?? this.expiresAt,
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
      if (externalDeliveryFeeId != null) 'id': externalDeliveryFeeId,
      if (vinkolAmount != null) 'vinkol_amount': vinkolAmount,
      'isAvailable': isAvailable,
      if (unavailableMessage != null) 'unavailableMessage': unavailableMessage,
      if (quoteId != null) 'quoteId': quoteId,
      if (serviceFee != null) 'serviceFee': serviceFee,
      if (taxAmount != null) 'taxAmount': taxAmount,
      if (taxRate != null) 'taxRate': taxRate,
      if (taxLabel != null) 'taxLabel': taxLabel,
      if (grandTotal != null) 'grandTotal': grandTotal,
      'currency': currency.code,
      'country': country.code,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    };
  }
}

/// Whether a failed order creation was rejected because its quote was stale.
///
/// The server answers 400 with "Quote has expired" or "This quote has already
/// been used". Both mean the same thing to the customer: re-price, and let them
/// confirm the new total.
bool isStaleQuoteMessage(String message) {
  final lower = message.toLowerCase();
  return lower.contains('quote') &&
      (lower.contains('expired') || lower.contains('already been used'));
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

class LatLngWithAddress {
  final double lat;
  final double lng;
  final String? address;

  LatLngWithAddress({
    required this.lat,
    required this.lng,
    this.address,
  });

  factory LatLngWithAddress.fromJson(Map<String, dynamic> json) {
    return LatLngWithAddress(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'lat': lat,
      'lng': lng,
    };
    if (address != null) data['address'] = address;
    return data;
  }
}

class RouteEndpoint {
  final LatLngWithAddress location;
  final String contact;
  final String? name;

  RouteEndpoint({
    required this.location,
    required this.contact,
    this.name,
  });

  factory RouteEndpoint.fromJson(Map<String, dynamic> json) {
    return RouteEndpoint(
      location:
          LatLngWithAddress.fromJson(json['location'] as Map<String, dynamic>),
      contact: json['contact'] as String,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'location': location.toJson(),
      'contact': contact,
    };
    if (name != null) data['name'] = name;
    return data;
  }
}

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
  /// The server-issued quote id, sent back as `quoteId` on order creation.
  final String quote;
  final double totalAmount;
  final double totalDistance;
  final List<BulkRoute> route;
  final int stops;

  /// Processing fee. Zero on Nigerian plain deliveries.
  final double? serviceFee;

  /// Tax resolved from the delivery's province. Zero in Nigeria.
  final double? taxAmount;

  /// The rate the tax was computed at, e.g. `0.13`.
  final double? taxRate;

  /// What to call the tax on the receipt, e.g. `HST` or `GST + QST`.
  final String? taxLabel;

  /// What the customer is charged. Equals [totalAmount] in Nigeria.
  final double? grandTotal;

  final Currency currency;

  /// The market the server resolved from the pickup coordinates. The client
  /// never chooses this — it reads it off the quote.
  final Country country;

  /// When the server stops accepting this quote. It issues a 15-minute window
  /// and returns the exact instant, so the expiry never has to be guessed.
  final DateTime? expiresAt;

  BulkQuoteResponse({
    required this.quote,
    required this.totalAmount,
    required this.totalDistance,
    required this.route,
    required this.stops,
    this.serviceFee,
    this.taxAmount,
    this.taxRate,
    this.taxLabel,
    this.grandTotal,
    this.currency = Currency.ngn,
    this.country = Country.ng,
    this.expiresAt,
  });

  /// What to charge and display, per the expansion guide: `grandTotal`, falling
  /// back to the fare when the server has not itemised the bill.
  Money get amountDue => Money(grandTotal ?? totalAmount, currency);

  Money get fare => Money(totalAmount, currency);

  Money? get serviceFeeMoney =>
      serviceFee == null ? null : Money(serviceFee!, currency);

  Money? get taxMoney => taxAmount == null ? null : Money(taxAmount!, currency);

  bool get hasItemisedCharges => (serviceFee ?? 0) > 0 || (taxAmount ?? 0) > 0;

  /// Whether this quote can still be used to create an order.
  bool get isExpired =>
      expiresAt != null && !DateTime.now().toUtc().isBefore(expiresAt!.toUtc());


  factory BulkQuoteResponse.fromJson(Map<String, dynamic> json) {
    return BulkQuoteResponse(
      quote: json['quote'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalDistance: (json['totalDistance'] as num).toDouble(),
      route: (json['route'] as List<dynamic>)
          .map((e) => BulkRoute.fromJson(e as Map<String, dynamic>))
          .toList(),
      stops: json['stops'] as int,
      serviceFee: Money.parseAmount(json['serviceFee']),
      taxAmount: Money.parseAmount(json['taxAmount']),
      taxRate: Money.parseAmount(json['taxRate']),
      taxLabel: json['taxLabel'] as String?,
      grandTotal: Money.parseAmount(json['grandTotal']),
      currency: Currency.fromCode(json['currency'] as String?),
      country: Country.fromCode(json['country'] as String?),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.tryParse(json['expiresAt'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quote': quote,
      'totalAmount': totalAmount,
      'totalDistance': totalDistance,
      'route': route.map((e) => e.toJson()).toList(),
      'stops': stops,
      if (serviceFee != null) 'serviceFee': serviceFee,
      if (taxAmount != null) 'taxAmount': taxAmount,
      if (taxRate != null) 'taxRate': taxRate,
      if (taxLabel != null) 'taxLabel': taxLabel,
      if (grandTotal != null) 'grandTotal': grandTotal,
      'currency': currency.code,
      'country': country.code,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    };
  }
}

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

  /// The server-issued quote id, sent back as `quoteId` on order creation.
  final String quote;
  final int totalOrders;
  final List<MultiOrderItem> orders;

  /// Processing fee. Zero on Nigerian plain deliveries.
  final double? serviceFee;

  /// Tax resolved from the delivery's province. Zero in Nigeria.
  final double? taxAmount;

  /// The rate the tax was computed at, e.g. `0.13`.
  final double? taxRate;

  /// What to call the tax on the receipt, e.g. `HST` or `GST + QST`.
  final String? taxLabel;

  /// What the customer is charged. Equals [totalAmount] in Nigeria.
  final double? grandTotal;

  /// Every pickup in a multi-order must be in the same country — one payment
  /// cannot span two currencies — so a single currency covers the whole basket.
  final Currency currency;

  /// The market the server resolved from the pickup coordinates. The client
  /// never chooses this — it reads it off the quote.
  final Country country;

  /// When the server stops accepting this quote. It issues a 15-minute window
  /// and returns the exact instant, so the expiry never has to be guessed.
  final DateTime? expiresAt;

  MultiOrderQuoteResponse({
    this.user,
    this.guest,
    required this.totalAmount,
    required this.quote,
    required this.totalOrders,
    this.orders = const [],
    this.serviceFee,
    this.taxAmount,
    this.taxRate,
    this.taxLabel,
    this.grandTotal,
    this.currency = Currency.ngn,
    this.country = Country.ng,
    this.expiresAt,
  });

  /// What to charge and display, per the expansion guide: `grandTotal`, falling
  /// back to the fare when the server has not itemised the bill.
  Money get amountDue => Money(grandTotal ?? totalAmount, currency);

  Money get fare => Money(totalAmount, currency);

  Money? get serviceFeeMoney =>
      serviceFee == null ? null : Money(serviceFee!, currency);

  Money? get taxMoney => taxAmount == null ? null : Money(taxAmount!, currency);

  bool get hasItemisedCharges => (serviceFee ?? 0) > 0 || (taxAmount ?? 0) > 0;

  /// Whether this quote can still be used to create an order.
  bool get isExpired =>
      expiresAt != null && !DateTime.now().toUtc().isBefore(expiresAt!.toUtc());


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
      serviceFee: Money.parseAmount(json['serviceFee']),
      taxAmount: Money.parseAmount(json['taxAmount']),
      taxRate: Money.parseAmount(json['taxRate']),
      taxLabel: json['taxLabel'] as String?,
      grandTotal: Money.parseAmount(json['grandTotal']),
      currency: Currency.fromCode(json['currency'] as String?),
      country: Country.fromCode(json['country'] as String?),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.tryParse(json['expiresAt'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'totalAmount': totalAmount,
      'quote': quote,
      'totalOrders': totalOrders,
      'currency': currency.code,
      'country': country.code,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      if (serviceFee != null) 'serviceFee': serviceFee,
      if (taxAmount != null) 'taxAmount': taxAmount,
      if (taxRate != null) 'taxRate': taxRate,
      if (taxLabel != null) 'taxLabel': taxLabel,
      if (grandTotal != null) 'grandTotal': grandTotal,
    };
    if (user != null) data['user'] = user;
    if (guest != null) data['guest'] = guest!.toJson();
    return data;
  }
}
