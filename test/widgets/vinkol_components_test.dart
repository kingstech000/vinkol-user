import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Wraps a component in a real Vinkol theme. Nothing here touches Riverpod, the locator or
/// the network layer — the component library must not depend on any of them.
Widget _host(Widget child,
    {Brightness brightness = Brightness.dark, bool reduceMotion = false}) {
  return MaterialApp(
    theme: brightness == Brightness.dark
        ? VinkolTheme.dark()
        : VinkolTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('status is never colour alone (D-05)', () {
    test('all six statuses have a distinct shape', () {
      final shapes = <VinkolStatusShape>{};
      for (final s in VinkolStatus.values) {
        shapes.add(VinkolColors.dark.statusStyle(s).shape);
      }
      // Six statuses, six shapes. A shared shape would leave colour doing the work, which
      // is exactly what D-05 forbids.
      expect(VinkolStatus.values, hasLength(6));
      expect(shapes, hasLength(6));
    });

    testWidgets('the chip renders its label, in every status', (tester) async {
      for (final s in VinkolStatus.values) {
        await tester.pumpWidget(_host(VinkolStatusChip(s)));
        final label = VinkolColors.dark.statusStyle(s).label;
        expect(find.text(label), findsOneWidget,
            reason: '$s must show its label');
      }
    });

    testWidgets('cancelled is neutral, not danger', (tester) async {
      final cancelled = VinkolColors.dark.statusStyle(VinkolStatus.cancelled);
      // Cancellation is an outcome, not an error; colouring it red trains users to ignore red.
      expect(cancelled.color, isNot(VinkolColors.dark.danger));
      expect(cancelled.color, VinkolColors.dark.textTertiary);
    });

    testWidgets('the pulsing status settles when reduced motion is on',
        (tester) async {
      await tester.pumpWidget(
        _host(const VinkolStatusChip(VinkolStatus.withRider),
            reduceMotion: true),
      );
      await tester.pump(const Duration(seconds: 1));
      // No pending frames means nothing is animating.
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('the pod (D-08)', () {
    final tabs = <VinkolPodTab>[
      const VinkolPodTab(icon: Icons.home_outlined, label: 'Home'),
      const VinkolPodTab(icon: Icons.storefront_outlined, label: 'Shop'),
      const VinkolPodTab(icon: Icons.inventory_2_outlined, label: 'Records'),
      const VinkolPodTab(
          icon: Icons.account_balance_wallet_outlined, label: 'Wallet'),
      const VinkolPodTab(icon: Icons.person_outline, label: 'Profile'),
    ];

    testWidgets('only the active tab reveals its label', (tester) async {
      await tester.pumpWidget(
        _host(VinkolPod(tabs: tabs, currentIndex: 2, onSelected: (_) {})),
      );
      expect(find.text('Records'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Wallet'), findsNothing);
    });

    testWidgets('every tab is reachable by a screen reader even unlabelled',
        (tester) async {
      await tester.pumpWidget(
        _host(VinkolPod(tabs: tabs, currentIndex: 0, onSelected: (_) {})),
      );
      for (final t in tabs) {
        expect(find.bySemanticsLabel(t.label), findsOneWidget);
      }
    });

    testWidgets('it stays dark in light mode', (tester) async {
      await tester.pumpWidget(
        _host(
          VinkolPod(tabs: tabs, currentIndex: 0, onSelected: (_) {}),
          brightness: Brightness.light,
        ),
      );
      // The pod is the one constant object across both themes (02-do-not-lose.md #2). The
      // two themes' pod values are near-identical but not byte-equal, so the assertion is
      // about luminance: in light mode the pod is still a dark object on a light canvas.
      expect(VinkolColors.light.podSurface, isNot(VinkolColors.light.surface));
      expect(VinkolColors.light.podSurface.computeLuminance(), lessThan(0.05));
      expect(VinkolColors.light.surface.computeLuminance(), greaterThan(0.9));
      // And its ink stays light, so contrast holds.
      expect(VinkolColors.light.podOn, VinkolColors.dark.podOn);
    });

    testWidgets('a tap reports the index', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        _host(VinkolPod(
            tabs: tabs, currentIndex: 0, onSelected: (i) => tapped = i)),
      );
      await tester.tap(find.bySemanticsLabel('Wallet'));
      expect(tapped, 3);
    });

    testWidgets('a disabled tab keeps its slot but does not fire',
        (tester) async {
      int? tapped;
      final withDisabled = <VinkolPodTab>[
        ...tabs.take(4),
        const VinkolPodTab(
            icon: Icons.person_outline, label: 'Profile', enabled: false),
      ];
      await tester.pumpWidget(
        _host(VinkolPod(
            tabs: withDisabled,
            currentIndex: 0,
            onSelected: (i) => tapped = i)),
      );
      expect(find.bySemanticsLabel('Profile'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Profile'));
      expect(tapped, isNull);
    });

    testWidgets('the pod has exactly five destinations', (tester) async {
      // The guard lives in build so the constructor can stay const, so it has to be pumped
      // rather than merely constructed.
      await tester.pumpWidget(
        _host(VinkolPod(
          tabs: tabs.take(4).toList(),
          currentIndex: 0,
          onSelected: (_) {},
        )),
      );
      expect(tester.takeException(), isAssertionError);
    });
  });

  group('renders in both themes', () {
    final samples = <String, Widget>{
      'hero': const VinkolHeroCard(
        eyebrow: 'Active delivery',
        reference: 'VK-4471-2290',
        headline: '18',
        headlineUnit: 'min',
        subtitle: 'Arriving shortly',
        badge: 'With rider',
        live: true,
        origin: VinkolHeroStop(label: 'From', place: 'Yaba'),
        destination: VinkolHeroStop(label: 'To', place: 'Lekki'),
        contact: VinkolHeroContact(name: 'Chidi O.', meta: 'Motorcycle'),
      ),
      'stops rail': const VinkolStopsRail(
        stops: <VinkolStop>[
          VinkolStop(label: 'Pickup', place: '12 Herbert Macaulay Way'),
          VinkolStop(label: 'Drop-off', placeholder: 'Where to?'),
        ],
      ),
      'progress track':
          const VinkolProgressTrack(step: 2, from: 'Yaba', to: 'Lekki'),
      'row group': VinkolRowGroup(
        children: <VinkolRow>[
          const VinkolRow(
              title: 'Wallet', meta: 'Pay from balance', value: '12,400'),
          VinkolRow(title: 'Card', icon: Icons.credit_card, onTap: () {}),
        ],
      ),
      'record card': const VinkolRecordCard(
        reference: 'VK-4471-2290',
        referenceLabel: 'Order',
        status: VinkolStatusChip(VinkolStatus.delivered),
        origin: 'Yaba',
        destination: 'Lekki',
        value: '3,200',
      ),
      'form field': const VinkolFormField(
        label: 'Recipient name',
        hint: 'Who is receiving this?',
        error: 'Enter the name on the door.',
      ),
      'segmented': VinkolSegmentedControl(
        segments: const <VinkolSegment>[
          VinkolSegment(label: 'One drop'),
          VinkolSegment(label: 'Multi-drop'),
        ],
        selectedIndex: 0,
        onSelected: (_) {},
      ),
      'data grid': const VinkolDataGrid(
        data: <VinkolDatum>[
          VinkolDatum(label: 'Distance', value: '8.4 km', numeric: true),
          VinkolDatum(label: 'Vehicle', value: 'Motorcycle'),
        ],
      ),
      'event row': const VinkolEventRow(
        title: 'Picked up',
        meta: '12 Herbert Macaulay Way',
        time: '09:41',
        date: 'Today',
        done: true,
      ),
      'quick action': VinkolQuickAction(
        icon: Icons.send_outlined,
        label: 'Send a package',
        onTap: () {},
      ),
      'chip row': VinkolChipRow(
        labels: const <String>['All', 'Pending', 'Delivered'],
        selectedIndex: 0,
        onSelected: (_) {},
      ),
    };

    for (final brightness in Brightness.values) {
      for (final entry in samples.entries) {
        testWidgets('${entry.key} · ${brightness.name}', (tester) async {
          await tester.pumpWidget(_host(entry.value, brightness: brightness));
          await tester.pump(const Duration(milliseconds: 300));
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('flush numerics survive a long label', () {
    testWidgets('the row truncates the title, never the amount',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 300,
            child: VinkolRow(
              title:
                  'An extremely long payment method name that cannot possibly fit',
              value: 'CA\$1,234.56',
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      // The amount is rendered whole; only the title carries the ellipsis.
      final amount = tester.widget<Text>(find.text('CA\$1,234.56'));
      expect(amount.overflow, isNot(TextOverflow.ellipsis));
    });
  });

  group('form field states', () {
    testWidgets('an error is words, tied to the field and announced',
        (tester) async {
      await tester.pumpWidget(
        _host(const VinkolFormField(
            label: 'Postal code', error: 'Enter it as A1A 1A1.')),
      );
      expect(find.text('Enter it as A1A 1A1.'), findsOneWidget);
      // liveRegion means a screen reader announces it rather than leaving it to be found.
      final semantics = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.text('Enter it as A1A 1A1.'),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.properties.liveRegion, isTrue);
    });

    testWidgets('the helper gives way to the error', (tester) async {
      await tester.pumpWidget(
        _host(const VinkolFormField(
          label: 'Postal code',
          helper: 'Six characters.',
          error: 'Enter it as A1A 1A1.',
        )),
      );
      expect(find.text('Six characters.'), findsNothing);
      expect(find.text('Enter it as A1A 1A1.'), findsOneWidget);
    });
  });
}
