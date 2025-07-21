import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/models/location_model.dart';

// Define a new CartState to hold the cart items, drop-off location, and delivery type
class CartState {
  final List<StoreProduct> products;
  final LocationModel? dropOffLocation;
  final String? currentCartStoreId;
  final String deliveryType; // Added delivery type, default to 'regular'

  CartState({
    required this.products,
    this.dropOffLocation,
    this.currentCartStoreId,
    this.deliveryType = 'regular', // Default value
  });

  CartState copyWith({
    List<StoreProduct>? products,
    LocationModel? dropOffLocation,
    String? currentCartStoreId,
    String? deliveryType, // Include in copyWith
  }) {
    return CartState(
      products: products ?? this.products,
      dropOffLocation: dropOffLocation ?? this.dropOffLocation,
      currentCartStoreId: currentCartStoreId ?? this.currentCartStoreId,
      deliveryType: deliveryType ?? this.deliveryType, // Include in copyWith
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    ref.listen(currentStoreProvider, (previousStore, nextStore) {
      if (nextStore != null &&
          state.currentCartStoreId != null &&
          nextStore.id != state.currentCartStoreId) {
        clearCart();
      }
    });
    return CartState(products: []);
  }

  void addProduct(StoreProduct product) {
    final newProductStoreId = product.store;

    if (state.products.isNotEmpty &&
        state.currentCartStoreId != null &&
        newProductStoreId != state.currentCartStoreId) {
      clearCart();
    }

    String? updatedCurrentCartStoreId = state.currentCartStoreId;
    if (newProductStoreId != null) {
      updatedCurrentCartStoreId = newProductStoreId;
    }

    final List<StoreProduct> updatedList = [];
    bool found = false;

    for (final item in state.products) {
      if (item.id == product.id) {
        found = true;
        updatedList.add(item.copyWith(quantity: (item.quantity ?? 0) + 1));
      } else {
        updatedList.add(item);
      }
    }

    if (!found) {
      updatedList.add(product.copyWith(quantity: 1));
    }

    state = state.copyWith(
        products: updatedList, currentCartStoreId: updatedCurrentCartStoreId);
  }

  void removeProduct(StoreProduct product) {
    final updatedProducts = [
      for (final item in state.products)
        if (item.id == product.id)
          item.copyWith(quantity: (item.quantity ?? 0) - 1)
        else
          item,
    ].where((item) => (item.quantity ?? 0) > 0).toList();

    state = state.copyWith(
      products: updatedProducts,
      currentCartStoreId: updatedProducts.isEmpty ? null : state.currentCartStoreId,
    );
  }

  void removeProductCompletely(StoreProduct product) {
    final updatedProducts =
        state.products.where((item) => item.id != product.id).toList();
    state = state.copyWith(
      products: updatedProducts,
      currentCartStoreId: updatedProducts.isEmpty ? null : state.currentCartStoreId,
    );
  }

  int getProductQuantity(StoreProduct product) {
    final existingProductInCart = state.products.firstWhere(
      (item) => item.id == product.id,
      orElse: () => product.copyWith(quantity: 0),
    );
    return existingProductInCart.quantity ?? 0;
  }

  void setDropOffLocation(LocationModel? location) {
    state = state.copyWith(dropOffLocation: location);
  }

  // New method to set the delivery type
  void setDeliveryType(String type) {
    state = state.copyWith(deliveryType: type);
  }

  int get totalItems =>
      state.products.fold(0, (sum, item) => sum + (item.quantity ?? 0));

  double get totalPrice => state.products
      .fold(0.0, (sum, item) => sum + (item.price * (item.quantity ?? 0)));

  void clearCart() {
    state = CartState(products: [], dropOffLocation: null, currentCartStoreId: null, deliveryType: 'regular');
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);