
import 'package:starter_codes/features/store/model/cart_item_model.dart';
import 'package:starter_codes/models/location_model.dart';

class StorePaymentArguments {
  final String storeId;
  final String storeName;
  final List<CartItem> cartItems;
  final double totalProductAmount; // Sum of item prices
  final double deliveryFee;
  final LocationModel? selectedDropoffLocation;
  final String formattedDropoffAddress; // The user-friendly address string
  final String deliveryType; // 'regular' or 'express'
  final String orderType; // 'delivery' or 'pickup'

  StorePaymentArguments({
    required this.storeId,
    required this.storeName,
    required this.cartItems,
    required this.totalProductAmount,
    required this.deliveryFee,
    this.selectedDropoffLocation,
    required this.formattedDropoffAddress,
    required this.deliveryType,
    required this.orderType,
  });
}