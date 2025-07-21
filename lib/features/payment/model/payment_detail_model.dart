// lib/models/payment_details_model.dart

import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/booking/model/request.dart';

class PaymentDetails {
   final String reference;

 
  final String? currency;
  final String? callbackUrl;
  final GetQuoteRequest? quoteRequest;
final QuoteResponseModel? quoteResponseModel;
  PaymentDetails({
    this.quoteRequest,
    this.quoteResponseModel,
    required this.reference,


    this.currency = 'NGN',
    this.callbackUrl,
  });
}