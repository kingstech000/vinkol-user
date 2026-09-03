import 'package:starter_codes/models/location_model.dart';

class CreateOrderRequest {
  final LocationModel pickupLocation;
  final LocationModel dropOffLocation;
  final String packageType;
  final String packageName;
  final String priorityType;
  final String vehicleType;
  final String estimatedDeliveryTime;
  final double price;
  final String pickupDate;
  final String pickupTime;
  final String note;
  final String state;
  final String? paymentSource;
  final String? deliveryProvider;
  final int? externalDeliveryFeeId;
  final String? description;
  final String? recipientName;
  final String? recipientPhone;

  CreateOrderRequest({
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.packageType,
    required this.packageName,
    required this.priorityType,
    required this.vehicleType,
    required this.estimatedDeliveryTime,
    required this.price,
    required this.pickupDate,
    required this.pickupTime,
    required this.note,
    required this.state,
    this.paymentSource,
    this.deliveryProvider,
    this.externalDeliveryFeeId,
    this.description,
    this.recipientName,
    this.recipientPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      "date": pickupDate,
      "time": pickupTime,
      'pickupLocation': pickupLocation.formattedAddress,
      'dropoffLocation': dropOffLocation.formattedAddress,
      'deliveryType': priorityType,
      'vehicleRequest': vehicleType,
      "orderType": "Delivery",
      'state': state,
      'deliveryFee': price,
      'itemType': packageName,
      // 'packageName': packageName,
      if (paymentSource != null) 'paymentSource': paymentSource,
      if (deliveryProvider != null) 'deliveryProvider': deliveryProvider,
      if (externalDeliveryFeeId != null)
        'externalDeliveryFeeId': externalDeliveryFeeId,
      if (description != null) 'description': description,
      if (note.isNotEmpty) 'note': note,
      if (recipientName != null && recipientPhone != null)
        "receiverContact": {"name": recipientName, "phone": recipientPhone}
    };
  }

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) {
    return CreateOrderRequest(
      state: json['state'] as String,
      pickupLocation: LocationModel.fromJson(
          json['pickupLocation'] as Map<String, dynamic>),
      dropOffLocation: LocationModel.fromJson(
          json['dropOffLocation'] as Map<String, dynamic>),
      packageType: json['packageType'] as String,
      packageName: json['packageName'] as String,
      priorityType: json['priorityType'] as String,
      vehicleType: json['vehicleType'] as String,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] as String,
      price: (json['price'] as num).toDouble(),
      pickupDate: json['pickupDate'] as String,
      pickupTime: json['pickupTime'] as String,
      note: json['note'] as String,
      paymentSource: json['paymentSource'] as String?,
      deliveryProvider: json['deliveryProvider'] as String?,
      externalDeliveryFeeId: json['externalDeliveryFeeId'] as int?,
      description: json['description'] as String?,
      recipientName: json['recipientName'] as String?,
      recipientPhone: json['recipientPhone'] as String?,
    );
  }

  CreateOrderRequest copyWith({
    LocationModel? pickupLocation,
    LocationModel? dropOffLocation,
    String? packageType,
    String? packageName,
    String? priorityType,
    String? vehicleType,
    String? estimatedDeliveryTime,
    double? price,
    String? pickupDate,
    String? pickupTime,
    String? note,
    String? paystackReference,
    String? state,
    String? paymentSource,
    String? deliveryProvider,
    int? externalDeliveryFeeId,
    String? description,
    String? recipientName,
    String? recipientPhone,
  }) {
    return CreateOrderRequest(
      state: state ?? this.state,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropOffLocation: dropOffLocation ?? this.dropOffLocation,
      packageType: packageType ?? this.packageType,
      packageName: packageName ?? this.packageName,
      priorityType: priorityType ?? this.priorityType,
      vehicleType: vehicleType ?? this.vehicleType,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      price: price ?? this.price,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTime: pickupTime ?? this.pickupTime,
      note: note ?? this.note,
      paymentSource: paymentSource ?? this.paymentSource,
      deliveryProvider: deliveryProvider ?? this.deliveryProvider,
      externalDeliveryFeeId:
          externalDeliveryFeeId ?? this.externalDeliveryFeeId,
      description: description ?? this.description,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
    );
  }
}

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
class GetQuoteRequest {
  final String state;
  final String orderType;
  final LocationData dropoffLocation;
  final LocationData pickupLocation;
  final String vehicleRequest;
  final String? userId;

  final String? note;
  final String? pickupTime;
  final String? pickupDate;
  final String? name;
  GetQuoteRequest({
    required this.state,
    this.name,
    this.note,
    this.pickupDate,
    this.pickupTime,
    required this.orderType,
    required this.dropoffLocation,
    required this.pickupLocation,
    required this.userId,
    // required this.deliveryType,
    required this.vehicleRequest,
  });

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'orderType': orderType,
      'dropoffLocation': dropoffLocation.toJson(),
      'pickupLocation': pickupLocation.toJson(),
      'vehicleRequest': vehicleRequest,
      'userId': userId,
    };
  }

  factory GetQuoteRequest.fromJson(Map<String, dynamic> json) {
    return GetQuoteRequest(
      state: json['state'] as String,
      orderType: json['orderType'] as String,
      dropoffLocation: LocationData.fromJson(
          json['dropoffLocation'] as Map<String, dynamic>),
      pickupLocation:
          LocationData.fromJson(json['pickupLocation'] as Map<String, dynamic>),
      vehicleRequest: json['vehicleRequest'] as String,
      userId: json['userId'] as String,
    );
  }

  GetQuoteRequest copyWith({
    String? state,
    String? orderType,
    LocationData? dropoffLocation,
    LocationData? pickupLocation,
    String? deliveryType,
    String? vehicleRequest,
    String? userId,
  }) {
    return GetQuoteRequest(
      state: state ?? this.state,
      orderType: orderType ?? this.orderType,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      vehicleRequest: vehicleRequest ?? this.vehicleRequest,
      userId: userId ?? this.userId,
    );
  }
}

class LocationData {
  final String lat;
  final String lng;
  final String address;

  LocationData({
    required this.lat,
    required this.lng,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      lat: json['lat'] as String,
      lng: json['lng'] as String,
      address: json['address'] as String,
    );
  }

  LocationData copyWith({
    String? lat,
    String? lng,
    String? address,
  }) {
    return LocationData(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
    );
  }
}

class LatLngNumber {
  final double lat;
  final double lng;
  final String? address;

  LatLngNumber({
    required this.lat,
    required this.lng,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'lat': lat.toString(),
      'lng': lng.toString(),
    };
    if (address != null) data['address'] = address;
    return data;
  }

  factory LatLngNumber.fromJson(Map<String, dynamic> json) {
    return LatLngNumber(
      lat: (json['lat'] is String
          ? double.tryParse(json['lat'] as String) ?? 0.0
          : (json['lat'] as num).toDouble()),
      lng: (json['lng'] is String
          ? double.tryParse(json['lng'] as String) ?? 0.0
          : (json['lng'] as num).toDouble()),
      address: json['address'] as String?,
    );
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

class Guest {
  final String email;
  final String firstname;
  final String lastname;
  final String phone;

  Guest({
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
    };
  }

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      email: json['email'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      phone: json['phone'] as String,
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
