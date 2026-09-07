import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:uuid/uuid.dart';

enum OrderType { standard, bulk, multi }

class StopModel {
  StopModel({
    required this.id,
    this.location,
    required this.isPickup,
    this.packageName = '',
    this.recipientName = '',
    this.recipientPhone = '',
    this.note = '',
  });

  final String id;
  final LocationModel? location;
  final bool isPickup;

  /// What is being carried to this drop-off. `BulkDropoffItem` and `MultiOrderRequestItem`
  /// each carry their own package and recipient, so these belong to the stop rather than to
  /// the order: at the moment you type the address for stop three, you know who it is for.
  final String packageName;
  final String recipientName;
  final String recipientPhone;
  final String note;

  /// Everything the API needs about this stop has been given.
  bool get isComplete =>
      location != null &&
      (isPickup ||
          (packageName.isNotEmpty &&
              recipientName.isNotEmpty &&
              recipientPhone.isNotEmpty));

  StopModel copyWith({
    LocationModel? location,
    bool? isPickup,
    String? packageName,
    String? recipientName,
    String? recipientPhone,
    String? note,
  }) {
    return StopModel(
      id: id,
      location: location ?? this.location,
      isPickup: isPickup ?? this.isPickup,
      packageName: packageName ?? this.packageName,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      note: note ?? this.note,
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

  /// When the rider should collect. `null` means as soon as one is found, which is what most
  /// bookings want and why it is the default rather than a required choice. The quote
  /// endpoints already take `pickupDate` and `pickupTime`, so this is the value the package
  /// form starts from rather than a new capability.
  final DateTime? pickupAt;

  RideLocationState({
    this.orderType = OrderType.standard,
    this.stops = const [],
    this.quoteResponses,
    this.quoteRequest,
    this.bulkQuoteResponse,
    this.bulkQuoteRequest,
    this.multiOrderQuoteResponse,
    this.pickupAt,
  });

  LocationModel? get pickUpLocation =>
      stops.where((s) => s.isPickup).firstOrNull?.location;
  LocationModel? get dropOffLocation =>
      stops.where((s) => !s.isPickup).firstOrNull?.location;

  List<StopModel> get pickups =>
      stops.where((StopModel s) => s.isPickup).toList();
  List<StopModel> get dropoffs =>
      stops.where((StopModel s) => !s.isPickup).toList();

  /// The batch flow stores its deliveries as consecutive pickup/drop-off pairs.
  List<({StopModel pickup, StopModel dropoff})> get deliveries =>
      <({StopModel pickup, StopModel dropoff})>[
        for (int i = 0; i + 1 < stops.length; i += 2)
          (pickup: stops[i], dropoff: stops[i + 1]),
      ];

  /// The order type the current stop set actually describes, whatever is selected.
  ///
  /// A second drop-off makes it multi-drop; a second pickup makes it a batch. The selector
  /// is a shortcut, not a gate — which is why this is derived rather than stored.
  OrderType get derivedOrderType {
    if (pickups.length > 1) return OrderType.multi;
    if (dropoffs.length > 1) return OrderType.bulk;
    return OrderType.standard;
  }

  /// Every stop has an address, and every drop-off has a package and a recipient.
  bool get isReadyForQuote =>
      stops.isNotEmpty && stops.every((StopModel s) => s.isComplete);

  RideLocationState copyWith({
    OrderType? orderType,
    List<StopModel>? stops,
    List<QuoteResponseModel>? quoteResponse,
    GetQuoteRequest? quoteRequest,
    BulkQuoteResponse? bulkQuoteResponse,
    GetNewBulkQuoteRequest? bulkQuoteRequest,
    MultiOrderQuoteResponse? multiOrderQuoteResponse,
    DateTime? pickupAt,
    bool clearPickupAt = false,
  }) {
    return RideLocationState(
      orderType: orderType ?? this.orderType,
      stops: stops ?? this.stops,
      quoteRequest: quoteRequest ?? this.quoteRequest,
      quoteResponses: quoteResponse ?? this.quoteResponses,
      bulkQuoteResponse: bulkQuoteResponse ?? this.bulkQuoteResponse,
      bulkQuoteRequest: bulkQuoteRequest ?? this.bulkQuoteRequest,
      multiOrderQuoteResponse:
          multiOrderQuoteResponse ?? this.multiOrderQuoteResponse,
      pickupAt: clearPickupAt ? null : (pickupAt ?? this.pickupAt),
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

  /// `null` books for now; a date sets a scheduled collection.
  void setPickupAt(DateTime? at) {
    state = at == null
        ? state.copyWith(clearPickupAt: true)
        : state.copyWith(pickupAt: at);
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

  void updateStopDetails(
    String id, {
    String? packageName,
    String? recipientName,
    String? recipientPhone,
    String? note,
  }) {
    state = state.copyWith(
      stops: state.stops.map((StopModel stop) {
        return stop.id == id
            ? stop.copyWith(
                packageName: packageName,
                recipientName: recipientName,
                recipientPhone: recipientPhone,
                note: note,
              )
            : stop;
      }).toList(),
    );
  }

  /// Reorders the drop-offs of a multi-drop, leaving the pickup where it is.
  ///
  /// This is the one edit on the multi-drop editor that changes the price, because the
  /// route is chained: stops run in the order the list shows them.
  void reorderDropoffs(int oldIndex, int newIndex) {
    final List<StopModel> dropoffs = state.dropoffs;
    if (oldIndex < 0 || oldIndex >= dropoffs.length) return;
    if (newIndex > oldIndex) newIndex -= 1;
    newIndex = newIndex.clamp(0, dropoffs.length - 1);
    if (newIndex == oldIndex) return;

    final StopModel moved = dropoffs.removeAt(oldIndex);
    dropoffs.insert(newIndex, moved);

    // Rebuild the flat list, dropping the reordered drop-offs back into the slots the
    // drop-offs already occupied so the pickup keeps its position.
    final Iterator<StopModel> next = dropoffs.iterator;
    state = state.copyWith(
      stops: state.stops.map((StopModel stop) {
        if (stop.isPickup) return stop;
        next.moveNext();
        return next.current;
      }).toList(),
    );
  }

  /// Switches between multi-drop and batch, carrying the stops across instead of resetting
  /// them the way [setOrderType] does.
  ///
  /// Multi-drop to batch gives every drop-off its own copy of the shared pickup; batch to
  /// multi-drop keeps the first pickup and chains every drop-off under it. Both are lossy in
  /// one direction only, and the direction that loses information is the one where the user
  /// has said the extra pickups do not matter.
  void convertOrderType(OrderType type) {
    if (type == state.orderType) return;
    const Uuid uuid = Uuid();
    final List<StopModel> dropoffs = state.dropoffs;
    final List<StopModel> pickups = state.pickups;
    if (dropoffs.isEmpty || pickups.isEmpty) {
      setOrderType(type);
      return;
    }

    switch (type) {
      case OrderType.bulk:
        state = state.copyWith(
          orderType: type,
          stops: <StopModel>[pickups.first, ...dropoffs],
        );
      case OrderType.multi:
        state = state.copyWith(
          orderType: type,
          stops: <StopModel>[
            for (int i = 0; i < dropoffs.length; i++) ...<StopModel>[
              i < pickups.length
                  ? pickups[i]
                  : StopModel(
                      id: uuid.v4(),
                      isPickup: true,
                      location: pickups.first.location,
                    ),
              dropoffs[i],
            ],
          ],
        );
      case OrderType.standard:
        setOrderType(type);
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
