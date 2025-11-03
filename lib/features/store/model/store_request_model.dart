class CreateStoreOrderPayload {
  final String state;
  final String store;
  final List<ProductOrderPayload> products;
  final int amount;
  final int deliveryFee;
  final String dropoffLocation;
  final String deliveryType;
  final String orderType;

  CreateStoreOrderPayload({
    required this.state,
    required this.store,
    required this.products,
    required this.amount,
    required this.deliveryFee,
    required this.dropoffLocation,
    required this.deliveryType,
    required this.orderType,
  });

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'store': store,
      'products': products.map((p) => p.toJson()).toList(),
      'amount': amount,
      'deliveryFee': deliveryFee,
      'dropoffLocation': dropoffLocation,
      'deliveryType': deliveryType,
      'orderType': orderType,
    };
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
