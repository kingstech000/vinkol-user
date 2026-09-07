import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/model/item_details.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/features/auth/model/user_model.dart';

/// Turns what the user filled in on the package-info form into the request
/// body each quote endpoint expects. One builder per order type, because the
/// three endpoints model the same trip in three different shapes.
class QuoteRequestBuilder {
  const QuoteRequestBuilder._();

  /// One pickup, one drop-off, one package.
  static GetQuoteRequest standard({
    required User? user,
    required String userState,
    required ItemDetails item,
    required LocationModel pickupLocation,
    required LocationModel dropOffLocation,
    required String pickupTime,
    required String pickupDate,
    required String vehicleRequest,
  }) {
    return GetQuoteRequest(
      userId: user?.id,
      note: item.noteController.text,
      name: item.packageNameController.text,
      pickupTime: pickupTime,
      pickupDate: pickupDate,
      pickupLocation: LocationData(
        lat: pickupLocation.coordinates!.latitude.toString(),
        lng: pickupLocation.coordinates!.longitude.toString(),
        address: pickupLocation.formattedAddress ?? '',
      ),
      dropoffLocation: LocationData(
        lat: dropOffLocation.coordinates!.latitude.toString(),
        lng: dropOffLocation.coordinates!.longitude.toString(),
        address: dropOffLocation.formattedAddress ?? '',
      ),
      state: userState,
      orderType: 'Delivery',
      vehicleRequest: vehicleRequest,
    );
  }

  /// One pickup, many drop-offs.
  ///
  /// [senderFallbackName] is used when the account has no name on it; the
  /// caller supplies it already localized.
  static GetNewBulkQuoteRequest bulk({
    required User? user,
    required String userState,
    required RideLocationState state,
    required String pickupDate,
    required String vehicleRequest,
    required String senderFallbackName,
  }) {
    final pickupLocation = state.pickups.first.location!;
    final dropoffStops = state.dropoffs;
    final senderName =
        '${user?.firstname ?? ''} ${user?.lastname ?? ''}'.trim();

    return GetNewBulkQuoteRequest(
      state: userState,
      orderType: 'Delivery',
      pickup: NewBulkPickup(
        location: LatLngNumber(
          lat: pickupLocation.coordinates!.latitude,
          lng: pickupLocation.coordinates!.longitude,
          address: pickupLocation.formattedAddress,
        ),
        // The pickup contact is whoever is sending, which is the account holder —
        // not, as it used to be, the recipient of the first drop-off.
        pickupContact: user?.phoneNumber ?? '',
        pickupName: senderName.isNotEmpty ? senderName : senderFallbackName,
      ),
      dropoffs: List.generate(dropoffStops.length, (i) {
        final dropoffLocation = dropoffStops[i].location!;
        return NewBulkDropoff(
          location: LatLngNumber(
            lat: dropoffLocation.coordinates!.latitude,
            lng: dropoffLocation.coordinates!.longitude,
            address: dropoffLocation.formattedAddress,
          ),
          dropoffContact: dropoffStops[i].recipientPhone,
          dropoffName: dropoffStops[i].recipientName,
        );
      }),
      deliveryType: 'bulk',
      vehicleRequest: vehicleRequest,
      guest: null,
      date: pickupDate,
      description: dropoffStops.first.packageName,
      note: dropoffStops.first.note,
      userId: user?.id,
    );
  }

  /// Several independent pickup-to-drop-off trips in one order.
  static GetNewMultiOrderQuoteRequest multiOrder({
    required User? user,
    required String userState,
    required RideLocationState state,
    required String vehicleRequest,
    required String senderFallbackName,
  }) {
    final senderName =
        '${user?.firstname ?? ''} ${user?.lastname ?? ''}'.trim();

    return GetNewMultiOrderQuoteRequest(
      orders: state.deliveries.map((delivery) {
        final pickupStop = delivery.pickup;
        final dropoffStop = delivery.dropoff;
        return NewMultiOrderItem(
          pickupLocation: LatLngNumber(
            lat: pickupStop.location!.coordinates!.latitude,
            lng: pickupStop.location!.coordinates!.longitude,
            address: pickupStop.location!.formattedAddress,
          ),
          // Sender on the pickup, recipient on the drop-off. These used to be the same
          // pair of values, which told the rider to hand the parcel back to the sender.
          pickupContact: NewMultiOrderPickupContact(
            name: senderName.isNotEmpty ? senderName : senderFallbackName,
            phone: user?.phoneNumber ?? '',
          ),
          dropoffLocation: LatLngNumber(
            lat: dropoffStop.location!.coordinates!.latitude,
            lng: dropoffStop.location!.coordinates!.longitude,
            address: dropoffStop.location!.formattedAddress,
          ),
          receiverContact: NewMultiOrderPickupContact(
            name: dropoffStop.recipientName,
            phone: dropoffStop.recipientPhone,
          ),
          state: userState,
          note: dropoffStop.note,
          description: dropoffStop.packageName,
          vehicleRequest: vehicleRequest,
        );
      }).toList(),
      guest: null,
      userId: user?.id,
    );
  }
}
