import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/payment/model/order_initiation_response_model.dart';
import 'package:starter_codes/features/payment/view/payment_webview.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';

/// The tail of every booking, shared by the three quote screens.
///
/// Creating an order has exactly two outcomes and both were written out three times: the
/// backend hands back an authorization URL, which means a card payment to complete in the
/// webview, or it hands back nothing, which means the wallet already paid and only
/// verification is left. The batch flow adds a third case — a wallet-paid batch returns a
/// list of order ids and no single order to verify, so there is nothing to verify and the
/// user goes straight to their records.
///
/// Shopping orders take the same two paths — only the flag that tells the verification screen
/// which endpoint to poll differs.
Future<void> routeAfterOrder(
  BuildContext context,
  WidgetRef ref,
  OrderInitiationResponse response, {
  bool isBatch = false,
  bool isStoreOrder = false,
}) async {
  final String orderId = response.order?.id ??
      (response.orderIds?.isNotEmpty == true ? response.orderIds!.first : '');
  final String reference = response.reference ?? '';

  if (response.authorizationUrl != null &&
      response.authorizationUrl!.isNotEmpty) {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => PaymentWebViewScreen(
          paymentUrl: response.authorizationUrl!,
          orderId: orderId,
          reference: reference,
          isStoreOrder: isStoreOrder,
          isMultiOrder: isBatch,
        ),
      ),
    );
    return;
  }

  if (isBatch && response.order == null && response.orderIds != null) {
    AppStatusDialogs.showSuccess(
      context,
      context.l10n.bookingBatchBookedTitle,
      context.l10n.bookingBatchBookedBody(response.orderIds!.length),
      onClosed: () {
        // Tab 2 is Records — the batch is placed, so the useful next screen is the list of
        // deliveries it created, not a verification step there is nothing to verify.
        ref.read(navigationIndexProvider.notifier).state = 2;
        NavigationService.instance
            .navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
      },
    );
    return;
  }

  NavigationService.instance.navigateToReplaceAll(
    NavigatorRoutes.paymentVerificationScreen,
    argument: <String, dynamic>{
      'orderId': orderId,
      'reference': reference,
      'isStoreOrder': isStoreOrder,
      if (isBatch) 'isMultiOrder': true,
    },
  );
}

/// The message to show for a failed booking. A [Failure] carries a message the backend wrote
/// for a user; anything else is shown as-is rather than replaced with "something went wrong",
/// which tells the user nothing they did not already know.
void showBookingError(BuildContext context, Object error) {
  AppStatusDialogs.showError(
    context,
    error is Failure ? error.title : context.l10n.bookingCouldNotBookTitle,
    error is Failure ? error.message : error.toString(),
  );
}
