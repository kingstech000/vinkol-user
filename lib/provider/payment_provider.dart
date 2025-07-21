// lib/provider/payment_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/payment/model/payment_detail_model.dart';

// This provider will hold the PaymentDetails that need to be processed
final paymentDetailsProvider = StateProvider<PaymentDetails?>((ref) => null);

// Optional: You could also have a provider to track payment status
enum PaymentStatus { initial, processing, success, failed }

final paymentStatusProvider = StateProvider<PaymentStatus>((ref) => PaymentStatus.initial);