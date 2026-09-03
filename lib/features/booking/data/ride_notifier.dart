import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:uuid/uuid.dart';

enum OrderType { standard, bulk, multi }

class StopModel {
  final String id;
  final LocationModel? location;
  final bool isPickup;

  StopModel({required this.id, this.location, required this.isPickup});

  StopModel copyWith({LocationModel? location, bool? isPickup}) {
    return StopModel(
      id: id,
      location: location ?? this.location,
      isPickup: isPickup ?? this.isPickup,
    );
  }
}

class RideLocationState {
  final OrderType orderType;
  final List<StopModel> stops;
  final List<QuoteResponseModel>? quoteResponses;
  final GetQuoteRequest? quoteRequest;
  final BulkQuoteResponse? bulkQuoteResponse;
  final GetNewBulkQuoteRequest? bulkQuoteRequest;
  final MultiOrderQuoteResponse? multiOrderQuoteResponse;

  RideLocationState({
    this.orderType = OrderType.standard,
    this.stops = const [],
    this.quoteResponses,
    this.quoteRequest,
    this.bulkQuoteResponse,
    this.bulkQuoteRequest,
    this.multiOrderQuoteResponse,
  });

  LocationModel? get pickUpLocation =>
      stops.where((s) => s.isPickup).firstOrNull?.location;
  LocationModel? get dropOffLocation =>
      stops.where((s) => !s.isPickup).firstOrNull?.location;

  RideLocationState copyWith({
    OrderType? orderType,
    List<StopModel>? stops,
    List<QuoteResponseModel>? quoteResponse,
    GetQuoteRequest? quoteRequest,
    BulkQuoteResponse? bulkQuoteResponse,
    GetNewBulkQuoteRequest? bulkQuoteRequest,
    MultiOrderQuoteResponse? multiOrderQuoteResponse,
  }) {
    return RideLocationState(
      orderType: orderType ?? this.orderType,
      stops: stops ?? this.stops,
      quoteRequest: quoteRequest ?? this.quoteRequest,
      quoteResponses: quoteResponse ?? this.quoteResponses,
      bulkQuoteResponse: bulkQuoteResponse ?? this.bulkQuoteResponse,
      bulkQuoteRequest: bulkQuoteRequest ?? this.bulkQuoteRequest,
      multiOrderQuoteResponse: multiOrderQuoteResponse ?? this.multiOrderQuoteResponse,
    );
  }
}

class RideLocationNotifier extends StateNotifier<RideLocationState> {
  RideLocationNotifier() : super(RideLocationState()) {
    _initializeStops();
  }

  void _initializeStops() {
    state = state.copyWith(
      stops: [
        StopModel(id: const Uuid().v4(), isPickup: true),
        StopModel(id: const Uuid().v4(), isPickup: false),
      ],
    );
  }

  void setOrderType(OrderType type) {
    if (state.orderType == type) return;

    List<StopModel> newStops = [];
    const uuid = Uuid();
    final existingPickup =
        state.stops.where((s) => s.isPickup).firstOrNull?.location;
    final existingDropoff =
        state.stops.where((s) => !s.isPickup).firstOrNull?.location;

    switch (type) {
      case OrderType.standard:
      case OrderType.bulk:
      case OrderType.multi:
        newStops = [
          StopModel(id: uuid.v4(), isPickup: true, location: existingPickup),
          StopModel(id: uuid.v4(), isPickup: false, location: existingDropoff),
        ];
        break;
    }
    state = state.copyWith(orderType: type, stops: newStops);
  }

  void updateStopLocation(String id, LocationModel location) {
    state = state.copyWith(
      stops: state.stops.map((stop) {
        return stop.id == id ? stop.copyWith(location: location) : stop;
      }).toList(),
    );
  }

  void clearStopLocation(String id) {
    state = state.copyWith(
      stops: state.stops.map((stop) {
        return stop.id == id
            ? StopModel(id: stop.id, isPickup: stop.isPickup, location: null)
            : stop;
      }).toList(),
    );
  }

  void toggleStopType(String id) {
    state = state.copyWith(
      stops: state.stops.map((stop) {
        return stop.id == id ? stop.copyWith(isPickup: !stop.isPickup) : stop;
      }).toList(),
    );
  }

  void addStop() {
    final uuid = const Uuid();
    if (state.orderType == OrderType.bulk) {
      // Bulk: Add one dropoff
      final newStop = StopModel(id: uuid.v4(), isPickup: false);
      state = state.copyWith(stops: [...state.stops, newStop]);
    } else if (state.orderType == OrderType.multi) {
      // Multi: Add a pair (pickup and dropoff)
      final newPickup = StopModel(id: uuid.v4(), isPickup: true);
      final newDropoff = StopModel(id: uuid.v4(), isPickup: false);
      state = state.copyWith(stops: [...state.stops, newPickup, newDropoff]);
    }
  }

  void removeStop(String id) {
    if (state.orderType == OrderType.bulk) {
      final dropoffCount = state.stops.where((s) => !s.isPickup).length;
      final stopToRemove = state.stops.firstWhere((s) => s.id == id);
      if (!stopToRemove.isPickup && dropoffCount > 1) {
        state = state.copyWith(
          stops: state.stops.where((stop) => stop.id != id).toList(),
        );
      }
    } else if (state.orderType == OrderType.multi) {
      // For multi, we remove the pair. Find the index and remove index and index+1 (if pickup) or index-1 and index (if dropoff)
      final index = state.stops.indexWhere((s) => s.id == id);
      if (index == -1 || state.stops.length <= 2) return;

      List<StopModel> newStops = List.from(state.stops);
      if (state.stops[index].isPickup) {
        // It's a pickup, remove it and the next stop (assumed dropoff)
        newStops.removeRange(index, (index + 2).clamp(0, newStops.length));
      } else {
        // It's a dropoff, remove it and the previous stop (assumed pickup)
        newStops.removeRange((index - 1).clamp(0, newStops.length), index + 1);
      }
      state = state.copyWith(stops: newStops);
    }
  }

  void setPickUpLocation(LocationModel location) {
    final firstPickupId = state.stops.where((s) => s.isPickup).firstOrNull?.id;
    if (firstPickupId != null) {
      updateStopLocation(firstPickupId, location);
    }
  }

  void setDropOffLocation(LocationModel location) {
    final firstDropoffId =
        state.stops.where((s) => !s.isPickup).firstOrNull?.id;
    if (firstDropoffId != null) {
      updateStopLocation(firstDropoffId, location);
    }
  }

  void setQuoteResponse(List<QuoteResponseModel> quoteResponse) {
    state = state.copyWith(quoteResponse: quoteResponse);
  }

  void setQuoteRequest(GetQuoteRequest quoteRequest) {
    state = state.copyWith(quoteRequest: quoteRequest);
  }

  void setBulkQuoteResponse(BulkQuoteResponse bulkQuoteResponse) {
    state = state.copyWith(bulkQuoteResponse: bulkQuoteResponse);
  }

  void setBulkQuoteRequest(GetNewBulkQuoteRequest bulkQuoteRequest) {
    state = state.copyWith(bulkQuoteRequest: bulkQuoteRequest);
  }

  void clearQuoteResponse() {
    state = state.copyWith(quoteResponse: null);
  }

  void clearBulkQuote() {
    state = state.copyWith(bulkQuoteResponse: null, bulkQuoteRequest: null);
  }

  void setMultiOrderQuoteResponse(MultiOrderQuoteResponse response) {
    state = state.copyWith(multiOrderQuoteResponse: response);
  }

  void swapLocations() {
    if (state.stops.length != 2) return;
    final loc0 = state.stops[0].location;
    final loc1 = state.stops[1].location;

    state = state.copyWith(
      stops: [
        state.stops[0].copyWith(location: loc1),
        state.stops[1].copyWith(location: loc0),
      ],
    );
  }
}

final rideLocationProvider =
    StateNotifierProvider<RideLocationNotifier, RideLocationState>(
  (ref) => RideLocationNotifier(),
);
