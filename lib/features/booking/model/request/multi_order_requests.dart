import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/features/booking/model/request.dart';

// Multi-drop orders: several independent trips in one order.

class MultiOrderRequestItem {
  final LocationModel pickupLocation;
  final LocationModel dropoffLocation;
  final String packageName;
  final String recipientName;
  final String recipientPhone;
  final String? note;
  final String? packageType;

  MultiOrderRequestItem({
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.packageName,
    required this.recipientName,
    required this.recipientPhone,
    this.note,
    this.packageType,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickupLocation': pickupLocation.formattedAddress,
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

class CreateMultiOrderRequest {
  final List<MultiOrderRequestItem> orders;
  final String vehicleType;
  final String pickupDate;
  final String pickupTime;
  final String state;
  final double totalPrice;
  final String? paymentSource;

  CreateMultiOrderRequest({
    required this.orders,
    required this.vehicleType,
    required this.pickupDate,
    required this.pickupTime,
    required this.state,
    required this.totalPrice,
    this.paymentSource,
  });

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((o) => o.toJson()).toList(),
      'vehicleRequest': vehicleType,
      'date': pickupDate,
      'time': pickupTime,
      'state': state,
      'deliveryFee': totalPrice,
      'orderType': 'Multi',
      if (paymentSource != null) 'paymentSource': paymentSource,
    };
  }
}

// ---  GetQuoteRequest ---

class CreateNewMultiOrderRequest {
  final String quoteId;
  final String paymentSource;

  CreateNewMultiOrderRequest({
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

class NewMultiOrderPickupContact {
  final String name;
  final String phone;

  NewMultiOrderPickupContact({
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    };
  }

  factory NewMultiOrderPickupContact.fromJson(Map<String, dynamic> json) {
    return NewMultiOrderPickupContact(
      name: json['name'] as String,
      phone: json['phone'] as String,
    );
  }
}

class NewMultiOrderItem {
  final LatLngNumber pickupLocation;
  final NewMultiOrderPickupContact pickupContact;
  final LatLngNumber dropoffLocation;
  final NewMultiOrderPickupContact receiverContact;
  final String state;
  final String note;
  final String description;
  final String vehicleRequest;

  NewMultiOrderItem({
    required this.pickupLocation,
    required this.pickupContact,
    required this.dropoffLocation,
    required this.receiverContact,
    required this.state,
    required this.note,
    required this.description,
    required this.vehicleRequest,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickupLocation': pickupLocation.toJson(),
      'pickupContact': pickupContact.toJson(),
      'dropoffLocation': dropoffLocation.toJson(),
      'receiverContact': receiverContact.toJson(),
      'state': state,
      'note': note,
      'description': description,
      'vehicleRequest': vehicleRequest,
    };
  }

  factory NewMultiOrderItem.fromJson(Map<String, dynamic> json) {
    return NewMultiOrderItem(
      pickupLocation:
          LatLngNumber.fromJson(json['pickupLocation'] as Map<String, dynamic>),
      pickupContact: NewMultiOrderPickupContact.fromJson(
          json['pickupContact'] as Map<String, dynamic>),
      dropoffLocation: LatLngNumber.fromJson(
          json['dropoffLocation'] as Map<String, dynamic>),
      receiverContact: NewMultiOrderPickupContact.fromJson(
          json['receiverContact'] as Map<String, dynamic>),
      state: json['state'] as String,
      note: json['note'] as String,
      description: json['description'] as String,
      vehicleRequest: json['vehicleRequest'] as String,
    );
  }
}

class GetNewMultiOrderQuoteRequest {
  final List<NewMultiOrderItem> orders;
  final Guest? guest;
  final String? userId;

  GetNewMultiOrderQuoteRequest({
    required this.orders,
    this.guest,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'orders': orders.map((e) => e.toJson()).toList(),
    };
    if (guest != null) data['guest'] = guest!.toJson();
    if (userId != null) data['userId'] = userId;
    return data;
  }
}
