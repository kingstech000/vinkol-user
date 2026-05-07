// lib/features/wallet/model/payment_history_model.dart
import 'package:equatable/equatable.dart';

class PaymentHistory extends Equatable {
  final String id;
  final String orderId;
  final String userId;
  final double amount;
  final String status;
  final String reference;
  final String type;
  final String narration;
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
    required this.narration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['_id']?.toString() ?? '', // Use _id as the primary id
      orderId: json['order']?.toString() ?? '',
      userId: json['user']?.toString() ?? '',
      amount: (() {
        try {
          final val = json['amount'];
          if (val == null) return 0.0;
          if (val is num) return val.toDouble();
          return double.tryParse(val.toString()) ?? 0.0;
        } catch (_) {
          return 0.0;
        }
      })(),
      status: json['status']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      narration: json['narration']?.toString() ?? '',
      createdAt: (() {
        final raw = json['createdAt'];
        if (raw == null) return DateTime.now();
        if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
        return DateTime.now();
      })(),
      updatedAt: (() {
        final raw = json['updatedAt'] ?? json['createdAt'];
        if (raw == null) return DateTime.now();
        if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
        return DateTime.now();
      })(),
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
      'narration': narration,
      'createdAt':
          createdAt.toIso8601String(), // Convert DateTime to ISO 8601 string
      'updatedAt':
          updatedAt.toIso8601String(), // Convert DateTime to ISO 8601 string
      '__v':
          0, // Assuming __v is not directly used in the model for business logic
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
        narration,
        createdAt,
        updatedAt,
      ];
}
