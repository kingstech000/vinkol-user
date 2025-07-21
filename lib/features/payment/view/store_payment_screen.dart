import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/features/store/data/store_service.dart';
import 'package:starter_codes/features/store/model/store_payment_argument_model.dart';
import 'package:starter_codes/features/store/model/store_request_model.dart';
import 'package:starter_codes/provider/cart_provider.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/provider/navigation_provider.dart';
import 'package:starter_codes/provider/user_provider.dart'; //  // Assuming this provides showErrorSnackBar
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:starter_codes/features/payment/data/paystack_service.dart'; // Import your PaystackService
import 'package:starter_codes/core/utils/colors.dart'; // For AppColors.primary
import 'package:uuid/uuid.dart'; // For generating unique IDs


const _uuid = Uuid(); // For generating unique IDs

class StorePaymentScreen extends ConsumerStatefulWidget {
  static const routeName = '/store-payment-screen';
  final StorePaymentArguments arguments;

  const StorePaymentScreen({super.key, required this.arguments});

  @override
  ConsumerState<StorePaymentScreen> createState() => _StorePaymentScreenState();
}

class _StorePaymentScreenState extends ConsumerState<StorePaymentScreen> {
  WebViewController? _webViewController;
  bool _isLoadingWebView = true;
  String? _paystackAuthUrl;
  String? _paymentErrorMessage; // To display error message if payment fails to initiate
  late String _paymentReference; // Will be generated once

  @override
  void initState() {
    super.initState();
    _paymentReference = 'STORE_ORDER_${_uuid.v4()}'; // Generate once per screen instance

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appLoggerProvider).d('[StorePaymentScreen] initState: addPostFrameCallback triggered.');
      _initiatePaymentProcess();
    });
  }

  Future<void> _initiatePaymentProcess() async {
    final currentUser = ref.read(userProvider);
    final paystackService = ref.read(paystackServiceProvider);

    if (currentUser == null) {
    ref.read(appLoggerProvider).e('[StorePaymentScreen] Error: User information missing for payment.');
      _showSnackbar('User information not found. Please log in again.');
      if (mounted) Navigator.of(context).pop(false); // Indicate failure back to CartScreen
      return;
    }

    final totalAmount = widget.arguments.totalProductAmount + widget.arguments.deliveryFee;

    if (mounted) {
      setState(() {
        _isLoadingWebView = true;
        _paymentErrorMessage = null; // Clear previous errors
      });
    }

    try {
     ref.read(appLoggerProvider).d('[StorePaymentScreen] Calling PaystackService.initializePayment...');
      final String? authUrl = await paystackService.initializePayment(
        amount: totalAmount,
        email: currentUser.email,
        reference: _paymentReference,
        currency: 'NGN', // Assuming NGN, adjust if dynamic
        callbackUrl: 'https://your-app.com/paystack-callback', // **CRITICAL: Replace with your actual domain**
      );

      if (!mounted) return;

      if (authUrl != null) {
        _paystackAuthUrl = authUrl;
         ref.read(appLoggerProvider).i('[StorePaymentScreen] Received Paystack authorization URL: $_paystackAuthUrl');
        _initializeWebView(
          paystackAuthUrl: _paystackAuthUrl!,
          paymentReference: _paymentReference,
        );
      } else {
         ref.read(appLoggerProvider).e('[StorePaymentScreen] Failed to get Paystack authorization URL (service returned null).');
        setState(() {
          _paymentErrorMessage = 'Failed to initialize payment. Please try again.';
        });
        _showSnackbar(_paymentErrorMessage!);
        // Optionally, pop back or show a retry button without WebView
      }
    } catch (e, st) {
      if (!mounted) return;
       ref.read(appLoggerProvider).e('[StorePaymentScreen] Exception during payment initialization: $e\n$st', error: e, stackTrace: st);
      setState(() {
        _paymentErrorMessage = 'Error initializing payment: ${e.toString()}';
      });
      _showSnackbar(_paymentErrorMessage!);
      // Optionally, pop back or show a retry button without WebView
    } finally {
      if (mounted && _paystackAuthUrl == null) { // Only set loading to false if WebView didn't load
        setState(() {
          _isLoadingWebView = false;
        });
      }
    }
  }

  void _initializeWebView({
    required String paystackAuthUrl,
    required String paymentReference,
  }) {
     ref.read(appLoggerProvider).d('[StorePaymentScreen] _initializeWebView called with URL: $paystackAuthUrl');

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Can show a progress indicator here if desired
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoadingWebView = true;
              });
            }
             ref.read(appLoggerProvider).d('[StorePaymentScreen] WebView Page started loading: $url');
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoadingWebView = false;
              });
            }
             ref.read(appLoggerProvider).d('[StorePaymentScreen] WebView Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
             ref.read(appLoggerProvider).e('''
              [StorePaymentScreen] WebView Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
            ''');
            if (mounted) {
               setState(() {
                _paymentErrorMessage = 'Error loading payment page: ${error.description}';
              });
              _showSnackbar('Error loading payment page: ${error.description}');
            }
            _handlePaymentFailure();
          },
          onNavigationRequest: (NavigationRequest request) async {
             ref.read(appLoggerProvider).d('[StorePaymentScreen] WebView Navigating to: ${request.url}');

            // **CRITICAL: Replace 'your-app.com' with the actual domain you configure for Paystack callback**
            // This domain should be something you control and is set as a callback URL in your Paystack dashboard
            // OR if your backend handles the callback, this is the domain YOUR BACKEND redirects to after verifying.
            const String callbackDomain = 'your-app.com';

            if (request.url.contains(callbackDomain) && request.url.contains('trxref=$paymentReference')) {
               ref.read(appLoggerProvider).d('[StorePaymentScreen] Detected callback URL with reference. Initiating backend verification...');
              final paystackService = ref.read(paystackServiceProvider);
              try {
                final bool? isVerified = await paystackService.verifyPayment(reference: paymentReference);

                if (isVerified == true) { // Explicitly check for true
                  _handlePaymentSuccess();
                } else { // Handles false or null (if service returned null for some reason)
                  _handlePaymentFailure();
                }
              } catch (e, st) {
                 ref.read(appLoggerProvider).e('[StorePaymentScreen] Exception during payment verification: $e\n$st', error: e, stackTrace: st);
                _showSnackbar('Error verifying payment: ${e.toString()}');
                _handlePaymentFailure(); // Assume failure if verification API call fails
              }
              return NavigationDecision.prevent; // Prevent WebView from navigating to callback URL
            } else if (request.url.contains('paystack.com/close')) {
               ref.read(appLoggerProvider).d('[StorePaymentScreen] Detected Paystack close URL.');
              _handlePaymentFailure(); // User closed the modal
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(paystackAuthUrl));

    if (_webViewController!.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_webViewController!.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
       ref.read(appLoggerProvider).w('Attempted to show snackbar but widget was unmounted: $message');
    }
  }

  // Returns true for success, false for failure
  void _handlePaymentResult(bool success) {
    if (!mounted) {
      ref.read(appLoggerProvider).d('[StorePaymentScreen] _handlePaymentResult called but widget is unmounted.');
      return;
    }

    if (success) {
      ref.read(appLoggerProvider).i('[StorePaymentScreen] Payment successful. Proceeding to create order...');
      _showSnackbar('Payment successful! Creating your order...');
      _createStoreOrder(); // Now call the order creation logic
    } else {
      ref.read(appLoggerProvider).w('[StorePaymentScreen] Payment failed or cancelled.');
      _showSnackbar('Payment failed or was cancelled.');
      Navigator.of(context).pop(false); // Pop back to cart screen, indicating failure
    }
  }


  Future<void> _createStoreOrder() async {
    final storeService = ref.read(storeServiceProvider);

    final productPayloads = widget.arguments.cartItems.map((item) {
      return ProductOrderPayload(
        product: item.product.id,
        quantity: item.quantity,
      );
    }).toList();

    final totalProductAmount = widget.arguments.totalProductAmount;
    final deliveryFee = widget.arguments.deliveryFee;

    final orderPayload = CreateStoreOrderPayload(
      paystackReference: _paymentReference, // Use the same reference
      state: 'pending',
      store: widget.arguments.storeId,
      products: productPayloads,
      amount: totalProductAmount,
      deliveryFee: deliveryFee,
      dropoffLocation: widget.arguments.formattedDropoffAddress,
      deliveryType: widget.arguments.deliveryType,
      orderType: widget.arguments.orderType,
    );

    try {
     final orderResponse= await storeService.createStoreOrder(orderPayload);
      ref.read(appLoggerProvider).i('[StorePaymentScreen] Store order successfully created in backend.');

      // Clear the cart after successful order creation
      ref.read(cartProvider.notifier).clearCart(); // Assuming you have a clearCart method

      if (!mounted) return;
   
        ref.read(selectedDeliveryProvider.notifier).state =orderResponse;
        
        ref.read(comingFromBookingsScreenProvider.notifier).state=true;
     NavigationService.instance.navigateTo(NavigatorRoutes.storeOrderScreen);
    } catch (e, st) {
      ref.read(appLoggerProvider).e('[StorePaymentScreen] Failed to create store order after payment: $e\n$st', error: e, stackTrace: st);
      if (!mounted) return;
      _showSnackbar('Payment successful, but failed to place order. Please contact support.');
      Navigator.of(context).pop(false); // Go back to cart, indicating order failure
    }
  }


  // Renamed for clarity in this WebView flow
  void _handlePaymentSuccess() {
    _handlePaymentResult(true);
  }

  void _handlePaymentFailure() {
    _handlePaymentResult(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Store Order'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Prevent going back while payment is in progress
      ),
      body: Stack(
        children: [
          if (_webViewController != null && _paystackAuthUrl != null)
            WebViewWidget(controller: _webViewController!),

          if (_isLoadingWebView || _paystackAuthUrl == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    _paystackAuthUrl == null
                        ? 'Initializing payment...'
                        : 'Loading payment page...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          if (!_isLoadingWebView && _paymentErrorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      _paymentErrorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Clear error and retry payment initiation
                        setState(() {
                          _paymentErrorMessage = null;
                          _paystackAuthUrl = null; // Reset auth URL to re-initiate
                          _isLoadingWebView = true;
                        });
                        _initiatePaymentProcess();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Try Again'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // Go back to cart screen
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Go Back To Cart'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}