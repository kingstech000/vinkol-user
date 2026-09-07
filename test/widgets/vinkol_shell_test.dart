import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_skeleton.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_states.dart';

Widget _host(
  Widget child, {
  Brightness brightness = Brightness.dark,
  bool reduceMotion = false,
}) {
  return MaterialApp(
    theme: brightness == Brightness.dark
        ? VinkolTheme.dark()
        : VinkolTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('every state offers a way out', () {
    testWidgets('an empty state shows its own copy and an action',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(_host(
        VinkolStateView.empty(
          icon: Icons.local_shipping_outlined,
          title: 'No deliveries yet',
          message: 'Package deliveries you book will show up here.',
          action: VinkolStateAction(
            label: 'Send a package',
            onPressed: () => tapped = true,
          ),
        ),
      ));

      expect(find.text('No deliveries yet'), findsOneWidget);
      expect(find.text('Package deliveries you book will show up here.'),
          findsOneWidget);
      await tester.tap(find.text('Send a package'));
      // The whole point of replacing EmptyContent: the state is not a dead end.
      expect(tapped, isTrue);
    });

    testWidgets('an error states its cause, not "something went wrong"',
        (tester) async {
      await tester.pumpWidget(_host(
        VinkolStateView.error(
          title: 'Could not load your orders',
          message: 'The server returned 503.',
          action: VinkolStateAction(label: 'Try again', onPressed: () {}),
        ),
      ));
      expect(find.text('The server returned 503.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('offline is its own state, with a retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _host(VinkolStateView.offline(onRetry: () => retried = true)),
      );
      expect(find.text('No connection'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('a secondary action is optional and works', (tester) async {
      var back = false;
      await tester.pumpWidget(_host(
        VinkolStateView.empty(
          icon: Icons.storefront_outlined,
          title: 'No stores near you',
          message: 'Nothing is delivering to this address right now.',
          action: VinkolStateAction(label: 'Change address', onPressed: () {}),
          secondaryAction:
              VinkolStateAction(label: 'Go back', onPressed: () => back = true),
        ),
      ));
      await tester.tap(find.text('Go back'));
      expect(back, isTrue);
    });

    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await tester.pumpWidget(_host(
          VinkolStateView.offline(onRetry: () {}),
          brightness: brightness,
        ));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('skeletons', () {
    testWidgets('a row skeleton list holds six rows by default',
        (tester) async {
      await tester.pumpWidget(_host(const VinkolSkeletonList()));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(VinkolRowSkeleton), findsNWidgets(6));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the record shape renders too', (tester) async {
      await tester.pumpWidget(_host(
        const VinkolSkeletonList(shape: VinkolSkeletonShape.record, count: 3),
      ));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(VinkolRecordSkeleton), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the shimmer stops under reduced motion', (tester) async {
      await tester.pumpWidget(
        _host(const VinkolSkeletonList(count: 2), reduceMotion: true),
      );
      await tester.pump(const Duration(seconds: 1));
      // The blocks still hold the space; nothing animates.
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.byType(VinkolRowSkeleton), findsNWidgets(2));
    });

    testWidgets('a screen reader hears "Loading" once, not three rows',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const VinkolSkeletonList(count: 3)));
      await tester.pump(const Duration(milliseconds: 200));
      // One announcement for the whole list; the placeholder rows are excluded.
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      handle.dispose();
    });

    for (final brightness in Brightness.values) {
      testWidgets('shimmer renders in ${brightness.name}', (tester) async {
        await tester.pumpWidget(
          _host(const VinkolSkeletonList(count: 2), brightness: brightness),
        );
        await tester.pump(const Duration(milliseconds: 600));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
