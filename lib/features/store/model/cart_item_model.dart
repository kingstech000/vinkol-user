// lib/features/cart/model/cart_item_model.dart
import 'package:equatable/equatable.dart';
import 'package:starter_codes/features/store/model/store_model.dart'; // Assuming StoreProduct is here

class CartItem extends Equatable {
  final StoreProduct product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  // For equatable comparison
  @override
  List<Object?> get props => [product, quantity];

  // Optional: Add a copyWith for convenience if you modify CartItem instances
  CartItem copyWith({
    StoreProduct? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}