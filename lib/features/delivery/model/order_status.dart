/// The customer-facing status of an order.
///
/// The server keeps its own vocabulary — it calls an order a rider has
/// collected `Picked`, not `With rider` — so every status crosses into the UI
/// through [OrderStatus.parse], which maps the server's words onto the closed
/// set the design system allows (decision D-05). A word the server adds later
/// is never invented into one of those: it keeps its own label under
/// [OrderStatusKind.unknown] and renders in the neutral style, so a new backend
/// status reads as itself rather than as a wrong stage.
library;

enum OrderStatusKind {
  pending,
  withShopper,
  withRider,
  delivered,
  cancelled,
  unattended,
  unknown,
}

class OrderStatus {
  const OrderStatus._(this.kind, this.label);

  /// Which of the six the status is, or [OrderStatusKind.unknown].
  final OrderStatusKind kind;

  /// What to show the customer. For the six this is the canonical label; for an
  /// unrecognised status it is the server's own word, tidied for display.
  final String label;

  /// Whether the order is still moving through the stages. Cancelled and
  /// unattended orders left the track, and an unrecognised status cannot be
  /// placed on it, so drawing one for them would lie.
  bool get isOnTrack => switch (kind) {
        OrderStatusKind.pending ||
        OrderStatusKind.withShopper ||
        OrderStatusKind.withRider ||
        OrderStatusKind.delivered =>
          true,
        OrderStatusKind.cancelled ||
        OrderStatusKind.unattended ||
        OrderStatusKind.unknown =>
          false,
      };

  /// Whether the order is still on its way — placed but not yet delivered.
  /// This is when a customer wants to know where it is; once it is delivered,
  /// cancelled or unattended the outcome is the whole story.
  bool get isInProgress => switch (kind) {
        OrderStatusKind.pending ||
        OrderStatusKind.withShopper ||
        OrderStatusKind.withRider =>
          true,
        OrderStatusKind.delivered ||
        OrderStatusKind.cancelled ||
        OrderStatusKind.unattended ||
        OrderStatusKind.unknown =>
          false,
      };

  static OrderStatus parse(String? raw) {
    final normalized =
        raw?.toLowerCase().trim().replaceAll(RegExp(r'[\s_-]+'), ' ');
    if (normalized == null || normalized.isEmpty) {
      return const OrderStatus._(OrderStatusKind.unknown, 'Unknown');
    }

    switch (normalized) {
      case 'pending':
        return const OrderStatus._(OrderStatusKind.pending, 'Pending');
      case 'with shopper':
      case 'shopping':
        return const OrderStatus._(OrderStatusKind.withShopper, 'With shopper');
      // `Picked` is what the API returns once a rider has collected the order;
      // it arrives alongside `pickedAt` and an assigned `rider`.
      case 'picked':
      case 'picked up':
      case 'with rider':
        return const OrderStatus._(OrderStatusKind.withRider, 'With rider');
      case 'delivered':
        return const OrderStatus._(OrderStatusKind.delivered, 'Delivered');
      case 'cancelled':
      case 'canceled':
        return const OrderStatus._(OrderStatusKind.cancelled, 'Cancelled');
      case 'unattended':
        return const OrderStatus._(OrderStatusKind.unattended, 'Unattended');
      default:
        return OrderStatus._(
            OrderStatusKind.unknown, _sentenceCase(normalized));
    }
  }

  static String _sentenceCase(String value) =>
      value[0].toUpperCase() + value.substring(1);
}
