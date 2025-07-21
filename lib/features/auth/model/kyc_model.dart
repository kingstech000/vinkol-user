// lib/features/auth/model/kyc_data_model.dart

class KycDataModel {
  final Vehicle? vehicle;
  final Identification? identification;
  final String id; // Renamed from _id to id for Dart conventions
  final String user;

  KycDataModel({
    this.vehicle,
    this.identification,
    required this.id,
    required this.user,
  });

  factory KycDataModel.fromJson(Map<String, dynamic> json) {
    return KycDataModel(
      vehicle: json['vehicle'] != null
          ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      identification: json['identification'] != null
          ? Identification.fromJson(
              json['identification'] as Map<String, dynamic>)
          : null,
      id: json['_id'] as String,
      user: json['user'] as String,
    );
  }

  // Optional: toJson for sending data back to API if needed, though not directly for getKycStatus
  Map<String, dynamic> toJson() {
    return {
      'vehicle': vehicle?.toJson(),
      'identification': identification?.toJson(),
      '_id': id,
      'user': user,
    };
  }

  // Optional: copyWith for immutability and easy updates
  KycDataModel copyWith({
    Vehicle? vehicle,
    Identification? identification,
    String? id,
    String? user,
  }) {
    return KycDataModel(
      vehicle: vehicle ?? this.vehicle,
      identification: identification ?? this.identification,
      id: id ?? this.id,
      user: user ?? this.user,
    );
  }
}

class Vehicle {
  final String vehicleType;
  final String status;
  final ImageInfo
      image; // Renamed from image to imageInfo to avoid conflict with dart:ui.Image

  Vehicle({
    required this.vehicleType,
    required this.status,
    required this.image,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleType: json['vehicleType'] as String,
      status: json['status'] as String,
      image: ImageInfo.fromJson(json['image'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleType': vehicleType,
      'status': status,
      'image': image.toJson(),
    };
  }

  Vehicle copyWith({
    String? vehicleType,
    String? status,
    ImageInfo? image,
  }) {
    return Vehicle(
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
      image: image ?? this.image,
    );
  }
}

class Identification {
  final String idType;
  final String status;
  final ImageInfo image;

  Identification({
    required this.idType,
    required this.status,
    required this.image,
  });

  factory Identification.fromJson(Map<String, dynamic> json) {
    return Identification(
      idType: json['idType'] as String,
      status: json['status'] as String,
      image: ImageInfo.fromJson(json['image'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idType': idType,
      'status': status,
      'image': image.toJson(),
    };
  }

  Identification copyWith({
    String? idType,
    String? status,
    ImageInfo? image,
  }) {
    return Identification(
      idType: idType ?? this.idType,
      status: status ?? this.status,
      image: image ?? this.image,
    );
  }
}

class ImageInfo {
  final String imageUrl;
  final String cloudinaryId;

  ImageInfo({
    required this.imageUrl,
    required this.cloudinaryId,
  });

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      imageUrl: json['imageUrl'] as String,
      cloudinaryId: json['cloudinaryId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'cloudinaryId': cloudinaryId,
    };
  }

  ImageInfo copyWith({
    String? imageUrl,
    String? cloudinaryId,
  }) {
    return ImageInfo(
      imageUrl: imageUrl ?? this.imageUrl,
      cloudinaryId: cloudinaryId ?? this.cloudinaryId,
    );
  }
}
