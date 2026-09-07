import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/delivery/data/delivery_service.dart';
import 'package:starter_codes/features/payment/model/verification_status.dart';
import 'package:starter_codes/features/payment/view/widget/cancel_verification_dialog.dart';
import 'package:starter_codes/features/payment/view/widget/verification_action_buttons.dart';
import 'package:starter_codes/features/payment/view/widget/verification_status_icon.dart';
import 'package:starter_codes/features/payment/view/widget/verification_status_text.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/provider/navigation_provider.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';

class PaymentVerificationScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String reference;
  final bool isStoreOrder;
  final bool isMultiOrder;

  const PaymentVerificationScreen({
    super.key,
    required this.orderId,
    required this.reference,
    this.isStoreOrder = false,
    this.isMultiOrder = false,
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
          if (widget.isMultiOrder) {
            ref.read(navigationIndexProvider.notifier).state = 2;
            NavigationService.instance
                .navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
          } else {
            NavigationService.instance.navigateToReplaceAll(widget.isStoreOrder
                ? NavigatorRoutes.storeOrderScreen
                : NavigatorRoutes.bookingOrderScreen);
          }
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
    CancelVerificationDialog.show(context, onGoBack: _goBackToCart);
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
                  VerificationStatusIcon(
                    status: _verificationStatus,
                    pulseAnimation: _pulseAnimation,
                  ),
                  SizedBox(height: 40.h),
                  VerificationStatusText(_statusMessage),
                  SizedBox(height: 16.h),
                  VerificationSubtitleText(
                    status: _verificationStatus,
                    canCancel: _canCancelVerification,
                    pollCount: _pollCount,
                  ),
                  const Spacer(flex: 3),
                  VerificationActionButtons(
                    status: _verificationStatus,
                    canCancel: _canCancelVerification,
                    pollCount: _pollCount,
                    isStoreOrder: widget.isStoreOrder,
                    onCancel: _cancelVerification,
                    onRetry: _retryVerification,
                    onViewOrders: _viewOrderStatus,
                    onGoBack: _goBackToCart,
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
