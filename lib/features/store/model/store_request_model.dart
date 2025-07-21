class ProductOrderPayload {
  final String product; // This should be the product ID
  final int quantity;

  ProductOrderPayload({required this.product, required this.quantity});

  Map<String, dynamic> toJson() => {
        "product": product,
        "quantity": quantity,
      };
}

class CreateStoreOrderPayload {
  final String? paystackReference;
  final String state; // e.g., 'pending', 'processing', 'completed'
  final String store; // Store ID
  final List<ProductOrderPayload> products;
  final double amount; // Total product cost
  final double deliveryFee;
  final String dropoffLocation; // Formatted address string
  final String deliveryType; // e.g., 'regular', 'express'
  final String orderType; // e.g., 'delivery', 'pickup'

  CreateStoreOrderPayload({
    this.paystackReference,
    required this.state,
    required this.store,
    required this.products,
    required this.amount,
    required this.deliveryFee,
    required this.dropoffLocation,
    required this.deliveryType,
    required this.orderType,
  });

  Map<String, dynamic> toJson() => {
        "paystackReference": paystackReference,
        "state": state,
        "store": store,
        "products": products.map((p) => p.toJson()).toList(),
        "amount": amount,
        "deliveryFee": deliveryFee,
        "dropoffLocation": dropoffLocation,
        "deliveryType": deliveryType.toLowerCase(),
        "orderType": 'Shopping',
      };
}