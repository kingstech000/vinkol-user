import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/features/booking/model/request.dart';

// Batch orders: one pickup, many drop-offs.

class BulkDropoffItem {
  final LocationModel dropoffLocation;
  final String packageName;
  final String recipientName;
  final String recipientPhone;
  final String? note;
  final String? packageType;

  BulkDropoffItem({
    required this.dropoffLocation,
    required this.packageName,
    required this.recipientName,
    required this.recipientPhone,
    this.note,
    this.packageType,
  });

  Map<String, dynamic> toJson() {
    return {
      'dropoffLocation': dropoffLocation.formattedAddress,
      'packageName': packageName,
      'receiverContact': {
        'name': recipientName,
        'phone': recipientPhone,
      },
      if (note != null) 'note': note,
      if (packageType != null) 'packageType': packageType,
    };
  }
}

class CreateBulkOrderRequest {
  final LocationModel pickupLocation;
  final List<BulkDropoffItem> dropoffs;
  final String vehicleType;
  final String pickupDate;
  final String pickupTime;
  final String state;
  final double totalPrice;
  final String? paymentSource;

  CreateBulkOrderRequest({
    required this.pickupLocation,
    required this.dropoffs,
    required this.vehicleType,
    required this.pickupDate,
    required this.pickupTime,
    required this.state,
    required this.totalPrice,
    this.paymentSource,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickupLocation': pickupLocation.formattedAddress,
      'dropoffs': dropoffs.map((d) => d.toJson()).toList(),
      'vehicleRequest': vehicleType,
      'date': pickupDate,
      'time': pickupTime,
      'state': state,
      'deliveryFee': totalPrice,
      'orderType': 'Bulk',
      if (paymentSource != null) 'paymentSource': paymentSource,
    };
  }
}

class NewBulkPickup {
  final LatLngNumber location;
  final String pickupContact;
  final String pickupName;

  NewBulkPickup({
    required this.location,
    required this.pickupContact,
    required this.pickupName,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'pickupContact': pickupContact,
      'pickupName': pickupName,
    };
  }

  factory NewBulkPickup.fromJson(Map<String, dynamic> json) {
    return NewBulkPickup(
      location: LatLngNumber.fromJson(json['location'] as Map<String, dynamic>),
      pickupContact: json['pickupContact'] as String,
      pickupName: json['pickupName'] as String,
    );
  }
}

class NewBulkDropoff {
  final LatLngNumber location;
  final String dropoffContact;
  final String dropoffName;

  NewBulkDropoff({
    required this.location,
    required this.dropoffContact,
    required this.dropoffName,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'dropoffContact': dropoffContact,
      'dropoffName': dropoffName,
    };
  }

  factory NewBulkDropoff.fromJson(Map<String, dynamic> json) {
    return NewBulkDropoff(
      location: LatLngNumber.fromJson(json['location'] as Map<String, dynamic>),
      dropoffContact: json['dropoffContact'] as String,
      dropoffName: json['dropoffName'] as String,
    );
  }
}

class GetNewBulkQuoteRequest {
  final String state;
  final String orderType;
  final NewBulkPickup pickup;
  final List<NewBulkDropoff> dropoffs;
  final String deliveryType;
  final String vehicleRequest;
  final Guest? guest;
  final String date;
  final String description;
  final String note;
  final String? userId;

  GetNewBulkQuoteRequest({
    required this.state,
    required this.orderType,
    required this.pickup,
    required this.dropoffs,
    required this.deliveryType,
    required this.vehicleRequest,
    this.guest,
    required this.date,
    required this.description,
    required this.note,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'state': state,
      'orderType': orderType,
      'pickup': pickup.toJson(),
      'dropoffs': dropoffs.map((e) => e.toJson()).toList(),
      'deliveryType': deliveryType,
      'vehicleRequest': vehicleRequest,
      'date': date,
      'description': description,
      'note': note,
    };
    if (guest != null) data['guest'] = guest!.toJson();
    if (userId != null) data['userId'] = userId;
    return data;
  }
}

class CreateNewBulkOrderRequest {
  final String quoteId;
  final String paymentSource;

  CreateNewBulkOrderRequest({
    required this.quoteId,
    required this.paymentSource,
  });

  Map<String, dynamic> toJson() {
    return {
      'quoteId': quoteId,
      'paymentSource': paymentSource,
    };
  }
}
