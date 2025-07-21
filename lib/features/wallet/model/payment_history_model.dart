// lib/features/wallet/model/payment_history_model.dart
import 'package:equatable/equatable.dart';

class PaymentHistory extends Equatable {
  final String id;
  final String orderId; // Renamed from 'order' to be more explicit
  final String userId;  // Renamed from 'user' to be more explicit
  final double amount;
  final String status;
  final String reference;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentHistory({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.status,
    required this.reference,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['_id'] as String, // Use _id as the primary id
      orderId: json['order'] as String,
      userId: json['user'] as String,
      amount: (json['amount'] as num).toDouble(), // Cast num to double
      status: json['status'] as String,
      reference: json['reference'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String), // Parse ISO 8601 string to DateTime
      updatedAt: DateTime.parse(json['updatedAt'] as String), // Parse ISO 8601 string to DateTime
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'order': orderId,
      'user': userId,
      'amount': amount,
      'status': status,
      'reference': reference,
      'type': type,
      'createdAt': createdAt.toIso8601String(), // Convert DateTime to ISO 8601 string
      'updatedAt': updatedAt.toIso8601String(), // Convert DateTime to ISO 8601 string
      '__v': 0, // Assuming __v is not directly used in the model for business logic
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        userId,
        amount,
        status,
        reference,
        type,
        createdAt,
        updatedAt,
      ];
}