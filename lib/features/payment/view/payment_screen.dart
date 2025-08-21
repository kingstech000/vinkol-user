import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/payment/data/paystack_service.dart'; // Corrected path if needed
import 'package:starter_codes/features/payment/model/payment_detail_model.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/provider/payment_provider.dart';
import 'package:starter_codes/core/utils/colors.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  WebViewController? _controller;
  bool _isLoadingWebView = true;
  PaymentDetails? _paymentDetails;
  String? _paystackAuthUrl;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[PaymentScreen] initState: addPostFrameCallback triggered.');
      _initiatePaymentProcess();
    });
  }

  Future<void> _initiatePaymentProcess() async {
    _paymentDetails = ref.read(paymentDetailsProvider);
    final currentUser = ref.read(userProvider);

    if (_paymentDetails == null || currentUser == null) {
      debugPrint(
          '[PaymentScreen] Error: Payment details or user email missing.');
      _showSnackbar(
          'Payment details or user information not found. Please try again.');
      NavigationService.instance.goBack();
      return;
    }

    final paystackService = ref.read(paystackServiceProvider);

    if (mounted) {
      setState(() {
        _isLoadingWebView = true;
      });
    }

    try {
      final String? authUrl = await paystackService.initializePayment(
        amount: _paymentDetails!.quoteResponseModel!.price,
        email: currentUser.email,
        reference: _paymentDetails!.reference,
        currency: _paymentDetails!.currency ?? 'NGN',
        callbackUrl:
            'https://your-app.com/paystack-callback', // Set your actual callback URL here
      );

      if (authUrl != null) {
        _paystackAuthUrl = authUrl;
        debugPrint(
            '[PaymentScreen] Received Paystack authorization URL: $_paystackAuthUrl');
        _initializeWebView(
          paystackAuthUrl: _paystackAuthUrl!,
          paymentReference: _paymentDetails!.reference,
        );
      } else {
        // If authUrl is null, it means PaystackService returned null (soft failure)
        debugPrint(
            '[PaymentScreen] Failed to get Paystack authorization URL (service returned null).');
        _showSnackbar('Failed to initialize payment. Please try again.');
        NavigationService.instance.goBack();
      }
    } catch (e, st) {
      // Catch exceptions thrown by PaystackService
      debugPrint(
          '[PaymentScreen] Exception during payment initialization: $e\n$st');
      _showSnackbar('Error initializing payment: ${e.toString()}');
      NavigationService.instance.goBack();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWebView = false;
        });
      }
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      debugPrint(
          'Attempted to show snackbar but widget was unmounted: $message');
    }
  }

  void _initializeWebView({
    required String paystackAuthUrl,
    required String paymentReference,
  }) {
    debugPrint(
        '[PaymentScreen] _initializeWebView called with URL: $paystackAuthUrl');

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoadingWebView = true;
              });
            }
            debugPrint('[PaymentScreen] Page started loading: $url');
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoadingWebView = false;
              });
            }
            debugPrint('[PaymentScreen] Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              [PaymentScreen] Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
            ''');
            _showSnackbar('Error loading payment page: ${error.description}');
            _handlePaymentFailure();
          },
          onNavigationRequest: (NavigationRequest request) async {
            debugPrint('[PaymentScreen] Navigating to: ${request.url}');

            const String callbackDomain =
                'your-app.com'; // **CRITICAL: Replace with your actual domain for the callback URL**

            if (request.url.contains(callbackDomain) &&
                request.url.contains('trxref=$paymentReference')) {
              debugPrint(
                  '[PaymentScreen] Detected callback URL with reference. Initiating backend verification...');
              final paystackService = ref.read(paystackServiceProvider);
              try {
                final bool? isVerified = await paystackService.verifyPayment(
                    reference: paymentReference);

                if (isVerified == true) {
                  // Explicitly check for true
                  _handlePaymentSuccess();
                } else {
                  // Handles false or null (if service returned null for some reason)
                  _handlePaymentFailure();
                }
              } catch (e, st) {
                debugPrint(
                    '[PaymentScreen] Exception during payment verification: $e\n$st');
                _showSnackbar('Error verifying payment: ${e.toString()}');
                _handlePaymentFailure(); // Assume failure if verification API call fails
              }
              return NavigationDecision.prevent;
            } else if (request.url.contains('paystack.com/close')) {
              debugPrint('[PaymentScreen] Detected Paystack close URL.');
              _handlePaymentFailure();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(paystackAuthUrl));

    if (_controller!.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller!.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  void _handlePaymentSuccess() {
    if (!mounted) {
      debugPrint(
          '[PaymentScreen] _handlePaymentSuccess called but widget is unmounted.');
      return;
    }
    debugPrint('[PaymentScreen] Handling payment success.');
    ref.read(paymentStatusProvider.notifier).state = PaymentStatus.success;
    _showSnackbar('Payment Successful! Processing order...');
    NavigationService.instance.goBack();
  }

  void _handlePaymentFailure() {
    if (!mounted) {
      debugPrint(
          '[PaymentScreen] _handlePaymentFailure called but widget is unmounted.');
      return;
    }
    debugPrint('[PaymentScreen] Handling payment failure.');
    ref.read(paymentStatusProvider.notifier).state = PaymentStatus.failed;
    _showSnackbar('Payment Failed or Cancelled.');
    NavigationService.instance.goBack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.h4(
          'Proceed to Payment',
          color: AppColors.white,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: const Icon(Icons.chevron_left, color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          if (_controller != null && _paystackAuthUrl != null)
            WebViewWidget(controller: _controller!),
          if (_isLoadingWebView || _paystackAuthUrl == null)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          if (!_isLoadingWebView && _paystackAuthUrl == null)
            const Center(
                child: Text('Failed to load payment page. Please try again.')),
        ],
      ),
    );
  }
}
