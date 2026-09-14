import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/features/delivery/model/order_status.dart';

void main() {
  group('OrderStatus.parse', () {
    test('maps the server word "Picked" onto With rider', () {
      // The staging API returns `Picked` once a rider has collected the order.
      final status = OrderStatus.parse('Picked');

      expect(status.kind, OrderStatusKind.withRider);
      expect(status.label, 'With rider');
      expect(status.isOnTrack, isTrue);
    });

    test('maps the six canonical statuses', () {
      expect(OrderStatus.parse('Pending').kind, OrderStatusKind.pending);
      expect(
          OrderStatus.parse('With shopper').kind, OrderStatusKind.withShopper);
      expect(OrderStatus.parse('With rider').kind, OrderStatusKind.withRider);
      expect(OrderStatus.parse('Delivered').kind, OrderStatusKind.delivered);
      expect(OrderStatus.parse('Cancelled').kind, OrderStatusKind.cancelled);
      expect(OrderStatus.parse('Unattended').kind, OrderStatusKind.unattended);
    });

    test('is insensitive to case, padding and separators', () {
      expect(OrderStatus.parse('  PICKED_UP  ').label, 'With rider');
      expect(OrderStatus.parse('with-rider').label, 'With rider');
      expect(OrderStatus.parse('canceled').kind, OrderStatusKind.cancelled);
    });

    test('leaves cancelled and unattended off the stage track', () {
      expect(OrderStatus.parse('Cancelled').isOnTrack, isFalse);
      expect(OrderStatus.parse('Unattended').isOnTrack, isFalse);
    });

    test('shows an unrecognised status as itself rather than inventing a stage',
        () {
      final status = OrderStatus.parse('Awaiting_pickup');

      expect(status.kind, OrderStatusKind.unknown);
      expect(status.label, 'Awaiting pickup');
      expect(status.isOnTrack, isFalse);
    });

    test('falls back to Unknown when the server sends nothing', () {
      expect(OrderStatus.parse(null).label, 'Unknown');
      expect(OrderStatus.parse('   ').label, 'Unknown');
      expect(OrderStatus.parse(null).kind, OrderStatusKind.unknown);
    });
  });
}
