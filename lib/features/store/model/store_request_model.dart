class CreateStoreOrderPayload {
  final String state;
  final String store;
  final List<ProductOrderPayload> products;
  final int amount;
  final int
      deliveryFee; // Can be 0 if included in total or handled otherwise, but kept for legacy
  final String dropoffLocation;
  final String deliveryType;
  final String orderType;
  final String? date;
  final String? time;
  final String? note;
  final String? description;
  final String? paymentSource;
  final String? deliveryProvider;
  final int? externalDeliveryFeeId;

  CreateStoreOrderPayload({
    required this.state,
    required this.store,
    required this.products,
    required this.amount,
    required this.deliveryFee,
    required this.dropoffLocation,
    required this.deliveryType,
    required this.orderType,
    this.date,
    this.time,
    this.note,
    this.description,
    this.paymentSource,
    this.deliveryProvider,
    this.externalDeliveryFeeId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'state': state,
      'store': store,
      'products': products.map((p) => p.toJson()).toList(),
      'amount': amount,
      'deliveryFee': deliveryFee,
      'dropoffLocation': dropoffLocation,
      'deliveryType': deliveryType,
      'orderType': orderType,
    };

    if (date != null) data['date'] = date;
    if (time != null) data['time'] = time;
    if (note != null) data['note'] = note;
    if (description != null) data['description'] = description;
    if (paymentSource != null) data['paymentSource'] = paymentSource;
    if (deliveryProvider != null) data['deliveryProvider'] = deliveryProvider;
    if (externalDeliveryFeeId != null) {
      data['externalDeliveryFeeId'] = externalDeliveryFeeId;
    }

    return data;
  }
}

class ProductOrderPayload {
  final String product;
  final int quantity;

  ProductOrderPayload({
    required this.product,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'quantity': quantity,
    };
  }
}
