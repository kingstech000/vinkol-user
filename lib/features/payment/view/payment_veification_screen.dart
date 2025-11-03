import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/delivery/data/delivery_service.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/provider/navigation_provider.dart';
import 'package:starter_codes/provider/cart_provider.dart';

class PaymentVerificationScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String reference;
  final bool isStoreOrder;

  const PaymentVerificationScreen({
    super.key,
    required this.orderId,
    required this.reference,
    this.isStoreOrder = false,
  });

  @override
  ConsumerState<PaymentVerificationScreen> createState() =>
      _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState
    extends ConsumerState<PaymentVerificationScreen>
    with SingleTickerProviderStateMixin {
  Timer? _pollingTimer;
  int _pollCount = 0;
  static const int _maxPollAttempts = 40;
  static const Duration _pollInterval = Duration(seconds: 3);

  String _statusMessage = 'Verifying your payment...';
  VerificationStatus _verificationStatus = VerificationStatus.verifying;

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startPolling() {
    debugPrint(
        '[PaymentVerification] Starting payment verification polling for order: ${widget.orderId}');
    debugPrint('[PaymentVerification] Is Store Order: ${widget.isStoreOrder}');
    _pollOrderStatus();

    _pollingTimer = Timer.periodic(_pollInterval, (timer) {
      _pollCount++;
      debugPrint(
          '[PaymentVerification] Poll attempt $_pollCount/$_maxPollAttempts');

      if (_pollCount >= _maxPollAttempts) {
        debugPrint(
            '[PaymentVerification] Max poll attempts reached, showing timeout');
        _handleTimeout();
        return;
      }

      _pollOrderStatus();
    });
  }

  Future<void> _pollOrderStatus() async {
    try {
      final deliveryService = ref.read(deliveryServiceProvider);
      final delivery =
          await deliveryService.getDeliveryOrderById(widget.orderId);

      debugPrint(
          '[PaymentVerification] Order fetched - Payment Status: ${delivery.paymentStatus}, Order Status: ${delivery.status}');

      _handleOrderResponse(delivery);
    } catch (e) {
      debugPrint('[PaymentVerification] Error polling order status: $e');
    }
  }

  void _handleOrderResponse(DeliveryModel delivery) {
    final paymentStatus = delivery.paymentStatus?.toLowerCase() ?? 'pending';

    if (paymentStatus == 'successful' || paymentStatus == 'success') {
      _handleSuccessfulPayment(delivery);
    } else if (paymentStatus == 'failed' || paymentStatus == 'failure') {
      _handleFailedPayment(delivery);
    } else if (paymentStatus == 'pending') {
      if (mounted) {
        setState(() {
          _statusMessage = 'Payment is being processed...';
        });
      }
    }
  }

  void _handleSuccessfulPayment(DeliveryModel delivery) {
    debugPrint(
        '[PaymentVerification] Payment successful, navigating to order screen');
    _pollingTimer?.cancel();

    if (mounted) {
      setState(() {
        _verificationStatus = VerificationStatus.success;
        _statusMessage = 'Payment Successful!';
      });

      ref.read(selectedDeliveryProvider.notifier).state = delivery;
      ref.read(comingFromBookingsScreenProvider.notifier).state = true;

      // Clear cart if it's a store order
      if (widget.isStoreOrder) {
        ref.read(cartProvider.notifier).clearCart();
      }

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          NavigationService.instance.navigateToReplaceAll(widget.isStoreOrder
              ? NavigatorRoutes.storeOrderScreen
              : NavigatorRoutes.bookingOrderScreen);
        }
      });
    }
  }

  void _handleFailedPayment(DeliveryModel delivery) {
    debugPrint('[PaymentVerification] Payment failed');
    _pollingTimer?.cancel();

    if (mounted) {
      setState(() {
        _verificationStatus = VerificationStatus.failed;
        _statusMessage = 'Payment Failed';
      });
    }
  }

  void _handleTimeout() {
    debugPrint('[PaymentVerification] Verification timeout');
    _pollingTimer?.cancel();

    if (mounted) {
      setState(() {
        _verificationStatus = VerificationStatus.timeout;
        _statusMessage = 'Verification Timeout';
      });
    }
  }

  void _retryVerification() {
    setState(() {
      _verificationStatus = VerificationStatus.verifying;
      _statusMessage = 'Verifying your payment...';
      _pollCount = 0;
    });
    _startPolling();
  }

  void _goBackToCart() {
    NavigationService.instance.navigateToReplaceAll(
      widget.isStoreOrder
          ? NavigatorRoutes.cartScreen
          : NavigatorRoutes.mapWithQuoteScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusIcon(),
                  SizedBox(height: 32.h),
                  _buildStatusText(),
                  SizedBox(height: 16.h),
                  _buildSubtitleText(),
                  SizedBox(height: 48.h),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (_verificationStatus) {
      case VerificationStatus.verifying:
        return ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 60.w,
                height: 60.w,
                child: CircularProgressIndicator(
                  strokeWidth: 4.w,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ),
        );
      case VerificationStatus.success:
        return Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 80.w,
            color: Colors.green,
          ),
        );
      case VerificationStatus.failed:
        return Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cancel,
            size: 80.w,
            color: Colors.red,
          ),
        );
      case VerificationStatus.timeout:
        return Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.access_time,
            size: 80.w,
            color: Colors.orange,
          ),
        );
    }
  }

  Widget _buildStatusText() {
    return Text(
      _statusMessage,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildSubtitleText() {
    String subtitle;
    switch (_verificationStatus) {
      case VerificationStatus.verifying:
        subtitle = 'Please wait while we confirm your payment status...';
        break;
      case VerificationStatus.success:
        subtitle = 'Your order has been confirmed successfully!';
        break;
      case VerificationStatus.failed:
        subtitle =
            'Unfortunately, your payment could not be processed. Please try again.';
        break;
      case VerificationStatus.timeout:
        subtitle =
            'We\'re still processing your payment. You can check your order status later or retry verification.';
        break;
    }

    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.grey[600],
        height: 1.5,
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_verificationStatus == VerificationStatus.verifying) {
      return const SizedBox.shrink();
    }

    if (_verificationStatus == VerificationStatus.success) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (_verificationStatus == VerificationStatus.failed ||
            _verificationStatus == VerificationStatus.timeout)
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: _retryVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Retry Verification',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: OutlinedButton(
            onPressed: _goBackToCart,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary, width: 2.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              widget.isStoreOrder ? 'Back to Cart' : 'Back to Booking',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum VerificationStatus {
  verifying,
  success,
  failed,
  timeout,
}
