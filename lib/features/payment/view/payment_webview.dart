import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/widgets/modal/confirmation_dialog.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PaymentWebViewScreen extends ConsumerStatefulWidget {
  final String paymentUrl;
  final String orderId;
  final String reference;
  final bool isStoreOrder;
  final bool isWalletFunding;
  final bool isMultiOrder;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
    required this.reference,
    this.isStoreOrder = false,
    this.isWalletFunding = false,
    this.isMultiOrder = false,
  });

  @override
  ConsumerState<PaymentWebViewScreen> createState() =>
      _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasNavigatedAway = false;
  String _currentUrl = '';

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
            _currentUrl = url;
            setState(() {
              _isLoading = false;
            });
            _injectPaymentDetectionScript();
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

  /// Whether the page being shown is the gateway's own checkout, as opposed to
  /// a redirect back to us. Stripe and Paystack both host their own pages.
  bool _isGatewayCheckoutPage(String url) =>
      url.contains('checkout.stripe.com') || url.contains('paystack.com');

  void _checkForPaymentCompletion(String url) {
    // A gateway's own checkout page is not a completion, whatever words happen
    // to appear in its URL. Stripe's session ids in particular are opaque.
    if (_isGatewayCheckoutPage(url) &&
        !url.contains('charge/success') &&
        !url.contains('pay/success')) {
      return;
    }

    // Check for Paystack success indicators
    if (url.contains('success') ||
        url.contains('callback') ||
        url.contains('verify') ||
        url.contains('complete') ||
        url.contains('close') ||
        url.contains('trxref') ||
        url.contains('reference')) {
      debugPrint('[PaymentWebView] Payment completion detected from URL: $url');
      _navigateToVerification();
    }

    // Also check for Paystack's typical success page patterns
    if (url.contains('paystack.com') &&
        (url.contains('charge/success') || url.contains('pay/success'))) {
      debugPrint('[PaymentWebView] Paystack success page detected: $url');
      _navigateToVerification();
    }

    // Check for custom payment success scheme
    if (url.startsWith('payment-success://')) {
      debugPrint(
          '[PaymentWebView] Payment success detected via JavaScript: $url');
      _navigateToVerification();
    }
  }

  void _injectPaymentDetectionScript() {
    // Scrapes page text for Paystack's wording. Stripe's checkout has its own
    // copy and its own redirect, so running this there only risks a false
    // positive — the customer would see "payment complete" before it was.
    if (!_currentUrl.contains('paystack.com')) {
      return;
    }

    // Inject JavaScript to detect payment completion on Paystack pages
    _controller.runJavaScript('''
      (function() {
        // Check for success messages or buttons
        var checkSuccess = function() {
          var bodyText = document.body.innerText.toLowerCase();
          if (bodyText.includes('successful') || 
              bodyText.includes('payment successful') ||
              bodyText.includes('transaction successful')) {
            console.log('Payment success detected in page content');
            return true;
          }
          
          // Check for close/done buttons that typically appear after success
          var buttons = document.querySelectorAll('button');
          for (var i = 0; i < buttons.length; i++) {
            var btnText = buttons[i].innerText.toLowerCase();
            if (btnText.includes('done') || btnText.includes('close') || btnText.includes('finish')) {
              console.log('Success button detected');
              return true;
            }
          }
          return false;
        };
        
        if (checkSuccess()) {
          // Payment appears successful - trigger navigation
          setTimeout(function() {
            window.location.href = 'payment-success://complete';
          }, 1000);
        }
        
        // Monitor for dynamic content changes
        var observer = new MutationObserver(function() {
          if (checkSuccess()) {
            setTimeout(function() {
              window.location.href = 'payment-success://complete';
            }, 1000);
            observer.disconnect();
          }
        });
        
        observer.observe(document.body, {
          childList: true,
          subtree: true
        });
      })();
    ''');
  }

  void _navigateToVerification() {
    if (_hasNavigatedAway) return;
    _hasNavigatedAway = true;

    debugPrint('[PaymentWebView] Navigating to verification screen');
    debugPrint('[PaymentWebView] Order ID: ${widget.orderId}');
    debugPrint('[PaymentWebView] Reference: ${widget.reference}');
    debugPrint('[PaymentWebView] Is Store Order: ${widget.isStoreOrder}');

    if (widget.orderId.isEmpty && !widget.isMultiOrder) {
      debugPrint(
          '[PaymentWebView] Wallet funding detected, skipping verification');
      Navigator.of(context).pop(true);
      return;
    }

    NavigationService.instance.navigateToReplaceAll(
      NavigatorRoutes.paymentVerificationScreen,
      argument: {
        'orderId': widget.orderId,
        'reference': widget.reference,
        'isStoreOrder': widget.isStoreOrder,
        'isMultiOrder': widget.isMultiOrder,
      },
    );
  }

  void _showErrorAndNavigateToVerification() {
    if (_hasNavigatedAway) return;

    AppStatusDialogs.showError(
      context,
      'Issue Encountered',
      'Payment page encountered an issue. Verifying payment...',
    );

    Future.delayed(const Duration(seconds: 2), () {
      _navigateToVerification();
    });
  }

  Future<bool> _onWillPop() async {
    if (widget.isWalletFunding) {
      return true; // Simple pop for wallet funding, back to wallet screen
    }

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
            icon: const Icon(PhosphorIconsRegular.x, color: Colors.white),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                Navigator.of(context).pop();
              }
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
