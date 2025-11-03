import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';

final selectedDeliveryProvider = StateProvider<DeliveryModel?>((ref) => null);

final isCreatingOrderProvider = StateProvider<bool>((ref) => false);
