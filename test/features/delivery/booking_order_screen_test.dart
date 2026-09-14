import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/core/utils/network_client.dart';
import 'package:starter_codes/features/delivery/data/delivery_service.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/features/delivery/model/rider_rating_model.dart';
import 'package:starter_codes/features/delivery/view/screen/booking_order_screen.dart';
import 'package:starter_codes/features/delivery/view_model/delivery_detail_view_model.dart';
import 'package:starter_codes/provider/delivery_provider.dart';

/// Seeds one delivery and swallows the screen's fetch so the seed survives.
class _SeededDetails extends DeliveryDetailsViewModel {
  _SeededDetails(DeliveryModel delivery)
      : super(
          DeliveryService(NetworkClient(), const AppLogger(DeliveryService)),
          const AppLogger(DeliveryDetailsViewModel),
        ) {
    state = AsyncValue.data(delivery);
  }

  @override
  Future<void> fetchDeliveryById(String deliveryId,
      {bool refresh = false}) async {}
}

const _rider = AgentModel(
  id: 'r1',
  firstname: 'Oluwaseun',
  lastname: 'Adebayo',
  phone: '+2348035550142',
);

const _ngExpressWithRider = DeliveryModel(
  id: 'o2',
  trackingId: 'VIN88120034',
  status: 'Picked',
  deliveryType: 'express',
  orderType: 'delivery',
  pickupLocation: '12 Adeola Odeku Street, Victoria Island, Lagos',
  dropoffLocation: 'Gbagada Phase 2, Lagos',
  deliveryFee: 5542,
  totalAmount: 5542,
  orderOtp: 4471,
  note: 'Call on arrival, gate is usually locked.',
  date: '09-09-2026',
  time: '3:15 PM',
  deliveryAgent: _rider,
);

const _caPending = DeliveryModel(
  id: 'o1',
  trackingId: 'VIN14539577',
  status: 'pending',
  deliveryType: 'regular',
  orderType: 'delivery',
  pickupLocation: '150 Rosemount Avenue, York, ON, Canada',
  dropoffLocation: 'Toronto Pearson International Airport, ON',
  deliveryFee: 42.00,
  serviceFee: 1.50,
  taxAmount: 5.66,
  taxRate: 0.13,
  taxLabel: 'HST',
  grandTotal: 49.16,
  totalAmount: 49.16,
  orderOtp: 9706,
  date: '10-09-2026',
  time: '12:43 PM',
  country: Country.ca,
  currency: Currency.cad,
);

const _caDelivered = DeliveryModel(
  id: 'o3',
  trackingId: 'VIN69577968',
  status: 'delivered',
  deliveryType: 'regular',
  orderType: 'delivery',
  pickupLocation: '131 Mill Street, Toronto, ON, Canada',
  dropoffLocation: 'Eddystone Avenue, North York, ON, Canada',
  deliveryFee: 63.17,
  serviceFee: 2.84,
  taxAmount: 8.58,
  taxRate: 0.13,
  grandTotal: 74.59,
  totalAmount: 74.59,
  orderOtp: 1122,
  date: '07-09-2026',
  time: '8:35 PM',
  country: Country.ca,
  currency: Currency.cad,
);

Widget _harness(DeliveryModel delivery) {
  return ProviderScope(
    overrides: [
      selectedDeliveryProvider.overrideWith((ref) => delivery),
      deliveryDetailsViewModelProvider
          .overrideWith((ref) => _SeededDetails(delivery)),
      riderRatingProvider.overrideWith((ref, id) async =>
          const RiderRatingModel(avgRating: 4.8, ratingsCount: 12)),
    ],
    child: const ScreenUtilInit(
      designSize: Size(375, 812),
      child: MaterialApp(home: BookingOrderScreen()),
    ),
  );
}

Future<void> _pump(WidgetTester tester, DeliveryModel delivery) async {
  // A phone, not the 800x600 test default — the sheet sizes against it.
  tester.view.physicalSize = const Size(1206, 2622);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_harness(delivery));
  // Let the post-frame fetch, the map's async geocoding and the rating
  // future settle without waiting on real network.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'GOOGLE_MAP_API_KEY=test');
  });

  testWidgets('a Canadian order is priced in dollars with its tax line',
      (tester) async {
    await _pump(tester, _caPending);

    expect(find.text('Delivery fee'), findsOneWidget);
    expect(find.text('Service fee'), findsOneWidget);
    expect(find.text('HST (13%)'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('49.16'), findsOneWidget);
    expect(find.text('C\$'), findsNWidgets(4));
    expect(find.textContaining('₦'), findsNothing);
  });

  testWidgets('an un-itemised order shows only its total, and its note',
      (tester) async {
    await _pump(tester, _ngExpressWithRider);

    expect(find.text('Delivery fee'), findsNothing);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('₦'), findsOneWidget);
    expect(find.text('5,542'), findsOneWidget);
    expect(find.text('NOTE'), findsOneWidget);
    expect(
        find.text('Call on arrival, gate is usually locked.'), findsOneWidget);
  });

  testWidgets('a pending order without a rider can be cancelled',
      (tester) async {
    await _pump(tester, _caPending);
    expect(find.text('Cancel Order'), findsOneWidget);
    expect(find.text('9706'), findsOneWidget);
  });

  testWidgets('an express order already with a rider cannot be cancelled',
      (tester) async {
    await _pump(tester, _ngExpressWithRider);
    expect(find.text('Cancel Order'), findsNothing);
    expect(find.text('Oluwaseun Adebayo'), findsOneWidget);
    expect(find.text('YOUR RIDER'), findsOneWidget);
  });

  testWidgets('the map controls step aside once the sheet covers the map',
      (tester) async {
    await _pump(tester, _caPending);

    AnimatedOpacity backOpacity() => tester.widget<AnimatedOpacity>(
          find.ancestor(
            of: find.bySemanticsLabel('Back'),
            matching: find.byType(AnimatedOpacity),
          ),
        );

    expect(backOpacity().opacity, 1);

    // Drag the sheet from its resting 55% up to the top of the screen.
    final handle = find.byType(DraggableScrollableSheet);
    await tester.drag(handle, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(backOpacity().opacity, 0);
  });

  testWidgets('a short order caps the sheet at its own content height',
      (tester) async {
    await _pump(tester, _caDelivered);
    // The measured height arrives a frame after layout.
    await tester.pump();

    DraggableScrollableSheet sheet() =>
        tester.widget(find.byType(DraggableScrollableSheet));

    expect(sheet().maxChildSize, lessThan(0.95));
    expect(sheet().initialChildSize, lessThanOrEqualTo(sheet().maxChildSize));
    expect(sheet().minChildSize, lessThanOrEqualTo(sheet().initialChildSize));

    // With the sheet dragged fully open, the content ends where the sheet
    // ends: no empty run of white beneath the last card.
    await tester.drag(
        find.byType(DraggableScrollableSheet), const Offset(0, -800));
    await tester.pumpAndSettle();

    final screen = tester.getRect(find.byType(Scaffold));
    final header = tester.getRect(find.text('TRACKING ID'));
    final lastRow = tester.getRect(find.text('Placed'));
    // The sheet stopped short of the top of the screen...
    expect(header.top, greaterThan(screen.height * (1 - sheet().maxChildSize)));
    // ...and the last row sits just above its bottom padding.
    expect(screen.bottom - lastRow.bottom, lessThan(80));
  });

  testWidgets('a tall order keeps the full-height sheet', (tester) async {
    await _pump(tester, _ngExpressWithRider);
    await tester.pump();
    final sheet = tester.widget<DraggableScrollableSheet>(
        find.byType(DraggableScrollableSheet));
    expect(sheet.maxChildSize, 0.95);
    expect(sheet.initialChildSize, 0.55);
  });
}
