import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/booking/model/request.dart';

import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/features/booking/model/order_model.dart'; // Import QuoteResponseModel

class RideLocationState {
  final LocationModel? pickUpLocation;
  final LocationModel? dropOffLocation;
  final List<QuoteResponseModel>? quoteResponses; // Added to include quote data
final GetQuoteRequest? quoteRequest;
  RideLocationState(
      {this.pickUpLocation, this.dropOffLocation, this.quoteResponses, this.quoteRequest});

  RideLocationState copyWith({
    LocationModel? pickUpLocation,
    LocationModel? dropOffLocation,
    List<QuoteResponseModel>? quoteResponse, 
    GetQuoteRequest? quoteRequest,
  }) {
    return RideLocationState(
      quoteRequest: quoteRequest ?? this.quoteRequest,
      pickUpLocation: pickUpLocation ?? this.pickUpLocation,
      dropOffLocation: dropOffLocation ?? this.dropOffLocation,
      quoteResponses: quoteResponse ?? quoteResponses, // Include in copyWith
    );
  }
}

class RideLocationNotifier extends StateNotifier<RideLocationState> {
  RideLocationNotifier() : super(RideLocationState());

  void setPickUpLocation(LocationModel location) {
    state = state.copyWith(pickUpLocation: location);
  }

  void setDropOffLocation(LocationModel location) {
    state = state.copyWith(dropOffLocation: location);
  }

  void setQuoteResponse(List<QuoteResponseModel> quoteResponse) {
    state = state.copyWith(quoteResponse: quoteResponse);
  }




    void setQuoteRequest(GetQuoteRequest quoteRequest) {
    state = state.copyWith(quoteRequest: quoteRequest);
  }

  void clearQuoteResponse() {
    state = state.copyWith(quoteResponse: null);
  }

  void swapLocations() {
    final currentPickUp = state.pickUpLocation;
    final currentDropOff = state.dropOffLocation;
    state = state.copyWith(
      pickUpLocation: currentDropOff,
      dropOffLocation: currentPickUp,
    );
  }
}

final rideLocationProvider =
    StateNotifierProvider<RideLocationNotifier, RideLocationState>(
  (ref) => RideLocationNotifier(),
);
