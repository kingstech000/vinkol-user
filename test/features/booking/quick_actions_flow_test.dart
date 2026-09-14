import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/view/screen/delivery_type_screen.dart';
import 'package:starter_codes/features/booking/view/widget/quick_actions.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';

class _Seeded extends RideLocationNotifier {
  _Seeded(RideLocationState seed) {
    state = seed;
  }
}

Widget _app(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

void main() {
  testWidgets('the home screen offers the three things the app does',
      (tester) async {
    await tester.pumpWidget(_app(const QuickActions()));

    expect(find.text('Send a package'), findsOneWidget);
    expect(find.text('Shop on Vinkol'), findsOneWidget);
    expect(find.text('Track your order'), findsOneWidget);
  });

  testWidgets('Shop on Vinkol switches to the shop tab', (tester) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      _app(
        Consumer(builder: (context, ref, _) {
          container = ProviderScope.containerOf(context);
          return const QuickActions();
        }),
      ),
    );

    expect(container.read(navigationIndexProvider), 0);
    await tester.tap(find.text('Shop on Vinkol'));
    await tester.pump();
    expect(container.read(navigationIndexProvider), 1);
  });

  group('the delivery type chooser', () {
    final pickup = StopModel(id: 'p', isPickup: true);
    final dropoff = StopModel(id: 'd', isPickup: false);

    testWidgets('names all three shapes and marks none on a fresh booking',
        (tester) async {
      await tester.pumpWidget(_app(
        const DeliveryTypeScreen(),
        overrides: [
          rideLocationProvider.overrideWith(
              (ref) => _Seeded(RideLocationState(stops: [pickup, dropoff]))),
        ],
      ));

      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Bulk'), findsOneWidget);
      expect(find.text('Multi'), findsOneWidget);
      expect(find.text('CURRENT'), findsNothing);
    });

    testWidgets('marks the shape of a booking already in progress',
        (tester) async {
      final started = pickup.copyWith(
          location: LocationModel(formattedAddress: '23 Allen Avenue'));
      await tester.pumpWidget(_app(
        const DeliveryTypeScreen(),
        overrides: [
          rideLocationProvider.overrideWith((ref) => _Seeded(RideLocationState(
              orderType: OrderType.bulk, stops: [started, dropoff]))),
        ],
      ));

      expect(find.text('CURRENT'), findsOneWidget);
      expect(
        find.ancestor(of: find.text('CURRENT'), matching: find.byType(Row)),
        findsWidgets,
      );
      // It sits on the Bulk row, not another.
      final bulkRow = find
          .ancestor(of: find.text('Bulk'), matching: find.byType(Row))
          .first;
      expect(
        find.descendant(of: bulkRow, matching: find.text('CURRENT')),
        findsOneWidget,
      );
    });
  });
}
