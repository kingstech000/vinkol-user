import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/extensions/double_extension.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/features/delivery/model/order_status.dart';

class DeliveryItem {
  final String customerName;
  final String status;
  final String amount;
  final String address;
  final String timestamp;
  final Color statusColor;
  final String orderId;

  DeliveryItem({
    required this.customerName,
    required this.status,
    required this.amount,
    required this.address,
    required this.timestamp,
    required this.statusColor,
    required this.orderId,
  });

  /// Factory constructor to convert [DeliveryModel] to [DeliveryItem].
  factory DeliveryItem.fromDeliveryModel(DeliveryModel delivery) {
    // Status colors come off the token ramp, never from Material's palette. The
    // shape and the label are added by the widget that draws them — status is
    // never carried by color alone (decision D-05).
    final Color statusColor = switch (OrderStatus.parse(delivery.status).kind) {
      OrderStatusKind.delivered => VinkolPalette.successText,
      OrderStatusKind.pending => VinkolPalette.warningText,
      OrderStatusKind.withRider ||
      OrderStatusKind.withShopper =>
        VinkolPalette.brand600,
      OrderStatusKind.unattended => VinkolPalette.dangerText,
      // Cancellation is an outcome, not an error, so it reads neutral.
      OrderStatusKind.cancelled => VinkolPalette.neutral600,
      OrderStatusKind.unknown => VinkolPalette.neutral500,
    };

    // Use totalAmount for the display amount
    final formattedAmount = '${delivery.totalAmount?.toMoney()}';

    // Determine address based on orderType or deliveryType
    String displayAddress;
    if (delivery.orderType?.toLowerCase() == 'delivery' ||
        delivery.deliveryType == 'regular' ||
        delivery.deliveryType == 'express') {
      displayAddress = delivery.dropoffLocation ?? 'No Dropoff Location';
    } else if (delivery.orderType?.toLowerCase() == 'storedelivery') {
      displayAddress = delivery.pickupLocation ?? 'No Pickup Location';
    } else {
      displayAddress = 'Address N/A';
    }

    // Determine customer name/type based on orderType
    String displayCustomerName;
    if (delivery.orderType?.toLowerCase() == 'delivery') {
      displayCustomerName = delivery.orderType.toString();
    } else if (delivery.orderType?.toLowerCase() == 'shopping') {
      // For store delivery, you might want to show the store name if available in the model
      // For now, it's generic 'Store Order'
      displayCustomerName = delivery.orderType.toString();
    } else {
      displayCustomerName = 'Order Type N/A';
    }

    // Combine 'date' and 'time' for timestamp
    String formattedTimestamp = '';
    if (delivery.date != null && delivery.time != null) {
      try {
        // Attempt to parse the date and time strings.
        // Assuming date is "D-M-YYYY" and time is "HH:MM"
        // Adjust parsing if your format is different (e.g., "YYYY-MM-DD")
        final String dateTimeString = '${delivery.date} ${delivery.time}';
        formattedTimestamp = dateTimeString;
        // Format for display
        // DateFormat('dd-MM-yyyy hh:mm a').format(parsedDateTime);
      } catch (e) {
        debugPrint('Error parsing date/time: $e');
        formattedTimestamp = 'Invalid Date/Time';
      }
    }

    return DeliveryItem(
      orderId: delivery.id ?? UniqueKey().toString(),
      customerName: displayCustomerName,
      status: OrderStatus.parse(delivery.status).label,
      amount: formattedAmount,
      address: displayAddress,
      timestamp: formattedTimestamp,
      statusColor: statusColor,
    );
  }
}
