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
  bool _canCancelVerification =
      true; // Allow user to cancel if no payment detected

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
      // After 5 polls (15 seconds), assume user hasn't paid yet
      if (_pollCount >= 5) {
        setState(() {
          _canCancelVerification = true;
          _statusMessage = 'Waiting for payment confirmation...';
        });
      } else {
        if (mounted) {
          setState(() {
            _statusMessage = 'Payment is being processed...';
          });
        }
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
    NavigationService.instance.navigateTo(
      widget.isStoreOrder
          ? NavigatorRoutes.cartScreen
          : NavigatorRoutes.dashboardScreen,
    );
  }

  void _cancelVerification() {
    _pollingTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 48.w,
                  color: Colors.orange,
                ),
              ),

              SizedBox(height: 24.h),

              // Title
              Text(
                'Cancel Verification?',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              // Description
              Text(
                'If you\'ve already made payment, it will still be processed. You can check your order status in the Deliveries section later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              SizedBox(height: 28.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(color: AppColors.primary, width: 2.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Keep Waiting',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _goBackToCart();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        backgroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Go Back',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewOrderStatus() {
    _pollingTimer?.cancel();
    NavigationService.instance.navigateToReplaceAll(
      NavigatorRoutes.dashboardScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.05),
                Colors.white,
                Colors.white,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildStatusIcon(),
                  SizedBox(height: 40.h),
                  _buildStatusText(),
                  SizedBox(height: 16.h),
                  _buildSubtitleText(),
                  const Spacer(flex: 3),
                  _buildActionButtons(),
                  SizedBox(height: 32.h),
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
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulsing circle
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 160.w,
                height: 160.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Middle circle
            Container(
              width: 130.w,
              height: 130.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
            // Inner circle with icon
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: 50.w,
                  height: 50.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.w,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      case VerificationStatus.success:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 160.w,
              height: 160.w,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 130.w,
              height: 130.w,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF66BB6A),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 60.w,
                color: Colors.white,
              ),
            ),
          ],
        );
      case VerificationStatus.failed:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 160.w,
              height: 160.w,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 130.w,
              height: 130.w,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFEF5350),
                    Color(0xFFE57373),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.error_rounded,
                size: 60.w,
                color: Colors.white,
              ),
            ),
          ],
        );
      case VerificationStatus.timeout:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 160.w,
              height: 160.w,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 130.w,
              height: 130.w,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF9800),
                    Color(0xFFFFB74D),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.schedule_rounded,
                size: 60.w,
                color: Colors.white,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildStatusText() {
    return Text(
      _statusMessage,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 26.sp,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSubtitleText() {
    String subtitle;
    switch (_verificationStatus) {
      case VerificationStatus.verifying:
        if (_canCancelVerification && _pollCount >= 5) {
          subtitle =
              'Taking longer than expected? You can go back and check your order status later in the Deliveries section.';
        } else {
          subtitle = 'Please wait while we confirm your payment status...';
        }
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
            'Payment verification is taking longer than usual. If you\'ve completed payment, your order will be processed. Check the Deliveries section for updates.';
        break;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        subtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15.sp,
          color: Colors.grey[600],
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    // Show cancel button during verification if taking too long
    if (_verificationStatus == VerificationStatus.verifying) {
      if (_canCancelVerification && _pollCount >= 5) {
        return Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _cancelVerification,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(color: Colors.grey[300]!, width: 1.5.w),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.grey[700],
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Cancel & Go Back',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    if (_verificationStatus == VerificationStatus.success) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (_verificationStatus == VerificationStatus.failed ||
            _verificationStatus == VerificationStatus.timeout)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _retryVerification,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 22.w),
                  SizedBox(width: 8.w),
                  Text(
                    'Retry Verification',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: 12.h),
        if (_verificationStatus == VerificationStatus.timeout)
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _viewOrderStatus,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(color: AppColors.primary, width: 2.w),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt_rounded,
                      color: AppColors.primary, size: 22.w),
                  SizedBox(width: 8.w),
                  Text(
                    'View My Orders',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_verificationStatus == VerificationStatus.timeout)
          SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _goBackToCart,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: BorderSide(color: Colors.grey[300]!, width: 1.5.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              widget.isStoreOrder ? 'Back to Cart' : 'Back to Home',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
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
