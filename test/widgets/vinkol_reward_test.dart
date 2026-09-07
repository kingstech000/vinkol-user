import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/features/booking/view/widget/reward_widgets.dart';
import 'package:starter_codes/l10n/app_localizations.dart';

Widget _host(
  Widget child, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
  Locale locale = const Locale('en'),
  double width = 375,
  bool reduceMotion = false,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const <LocalizationsDelegate<Object>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: brightness == Brightness.dark
        ? VinkolTheme.dark()
        : VinkolTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(
        textScaler: TextScaler.linear(textScale),
        disableAnimations: reduceMotion,
      ),
      child: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

void main() {
  const states = <RewardProgress>[
    RewardProgress(completed: 0, earned: false),
    RewardProgress(completed: 1, earned: false),
    RewardProgress(completed: 2, earned: false),
    RewardProgress(completed: 3, earned: true),
  ];

  testWidgets(
      'the reward card lays out in every state, scale, theme and locale',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final p in states) {
      for (final b in Brightness.values) {
        for (final scale in <double>[1, 1.6, 2]) {
          for (final loc in const <Locale>[Locale('en'), Locale('fr')]) {
            await tester.pumpWidget(_host(
              RewardCard(progress: p, onTap: () {}),
              brightness: b,
              textScale: scale,
              locale: loc,
            ));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull,
                reason: 'RewardCard done=${p.done} $b x$scale $loc');
          }
        }
      }
    }
  });

  testWidgets('the earned card lays out on the saturated ground',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final scale in <double>[1, 2]) {
      await tester.pumpWidget(_host(
        const RewardEarnedCard(
            progress: RewardProgress(completed: 3, earned: true)),
        textScale: scale,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'earned x$scale');
    }
  });

  testWidgets('the route names every stop, so it reads without the copy',
      (tester) async {
    await tester.pumpWidget(_host(
      const RewardCard(progress: RewardProgress(completed: 2, earned: false)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsNWidgets(2));
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Reward'), findsOneWidget);
  });

  testWidgets('the destination reads as yours once earned', (tester) async {
    await tester.pumpWidget(_host(
      const RewardCard(progress: RewardProgress(completed: 3, earned: true)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Yours'), findsOneWidget);
    expect(find.text('Done'), findsNWidgets(3));
  });

  testWidgets('the meter card lays out in every state, scale, theme and locale',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final p in states) {
      for (final b in Brightness.values) {
        for (final scale in <double>[1, 1.6, 2]) {
          for (final loc in const <Locale>[Locale('en'), Locale('fr')]) {
            await tester.pumpWidget(_host(
              RewardMeterCard(progress: p, onTap: () {}),
              brightness: b,
              textScale: scale,
              locale: loc,
              // The earned card animates forever; settle would never return.
              reduceMotion: true,
            ));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull,
                reason: 'RewardMeterCard done=\${p.done} \$b x\$scale \$loc');
          }
        }
      }
    }
  });

  testWidgets('the celebration is ambient, and stops for reduced motion',
      (tester) async {
    const won = RewardProgress(completed: 3, earned: true);

    await tester.pumpWidget(_host(const RewardMeterCard(progress: won)));
    await tester.pump(const Duration(milliseconds: 400));
    // Rays, shine, bob and confetti are all running.
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(
      _host(const RewardMeterCard(progress: won), reduceMotion: true),
    );
    await tester.pumpAndSettle();
    // Reduced motion is a setting, not a preference to be overridden by a party.
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('an unearned card never animates', (tester) async {
    await tester.pumpWidget(_host(
      const RewardMeterCard(
          progress: RewardProgress(completed: 2, earned: false)),
    ));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  test('the meter fills the artwork\'s box, not its canvas', () {
    // Empty must read empty: the fill line sits at the base of the box (86% down the frame),
    // not at the base of the 500px canvas, which would show a third of the box coloured.
    double at(int done, {bool earned = false}) =>
        rewardMeterFillTop(RewardProgress(completed: done, earned: earned));

    expect(at(0), closeTo(0.86, 0.001));
    expect(at(1), closeTo(0.65, 0.001));
    expect(at(2), closeTo(0.44, 0.001));
    expect(at(3, earned: true), closeTo(0.23, 0.001));
  });
}
