import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/features/delivery/data/delivery_service.dart';
import 'package:starter_codes/features/delivery/model/rider_rating_model.dart';

final selectedDeliveryProvider = StateProvider<DeliveryModel?>((ref) => null);

final isCreatingOrderProvider = StateProvider<bool>((ref) => false);

// Provider for rider rating
final riderRatingProvider = FutureProvider.family<RiderRatingModel, String>(
  (ref, riderId) async {
    if (riderId.isEmpty) {
      return const RiderRatingModel(avgRating: 0.0, ratingsCount: 0);
    }
    final deliveryService = ref.read(deliveryServiceProvider);
    return await deliveryService.getRiderAverageRating(riderId);
  },
);
