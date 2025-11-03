import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/widgets/modal/confirmation_dialog.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentWebViewScreen extends ConsumerStatefulWidget {
  final String paymentUrl;
  final String orderId;
  final String reference;
  final bool isStoreOrder;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
    required this.reference,
    this.isStoreOrder = false,
  });

  @override
  ConsumerState<PaymentWebViewScreen> createState() =>
      _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasNavigatedAway = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    debugPrint(
        '[PaymentWebView] Initializing WebView with URL: ${widget.paymentUrl}');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('[PaymentWebView] Page started loading: $url');
            setState(() {
              _isLoading = true;
            });
            _checkForPaymentCompletion(url);
          },
          onPageFinished: (String url) {
            debugPrint('[PaymentWebView] Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('[PaymentWebView] Error: ${error.description}');
            _showErrorAndNavigateToVerification();
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint(
                '[PaymentWebView] Navigation request to: ${request.url}');
            _checkForPaymentCompletion(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkForPaymentCompletion(String url) {
    if (url.contains('success') ||
        url.contains('callback') ||
        url.contains('verify') ||
        url.contains('complete') ||
        url.contains('close')) {
      debugPrint('[PaymentWebView] Payment completion detected from URL: $url');
      _navigateToVerification();
    }
  }

  void _navigateToVerification() {
    if (_hasNavigatedAway) return;
    _hasNavigatedAway = true;

    debugPrint('[PaymentWebView] Navigating to verification screen');
    debugPrint('[PaymentWebView] Order ID: ${widget.orderId}');
    debugPrint('[PaymentWebView] Reference: ${widget.reference}');
    debugPrint('[PaymentWebView] Is Store Order: ${widget.isStoreOrder}');

    NavigationService.instance.navigateToReplaceAll(
      NavigatorRoutes.paymentVerificationScreen,
      argument: {
        'orderId': widget.orderId,
        'reference': widget.reference,
        'isStoreOrder': widget.isStoreOrder,
      },
    );
  }

  void _showErrorAndNavigateToVerification() {
    if (_hasNavigatedAway) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Payment page encountered an issue. Verifying payment...'),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      _navigateToVerification();
    });
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PaymentConfirmationDialog(
        isStoreOrder: widget.isStoreOrder,
      ),
    );

    if (result == 'verify') {
      _navigateToVerification();
      return false;
    } else if (result == true) {
      return true; // Cancel and go back
    }

    return false; // Continue payment
  }

  @override
  Widget build(BuildContext context) {
    log('IsFromStore: ${widget.isStoreOrder}');
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              await _onWillPop();
            },
          ),
          title: const Text(
            'Complete Payment',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50.w,
                        height: 50.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 4.w,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading payment page...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
