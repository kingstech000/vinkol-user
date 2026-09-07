import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/l10n/app_localizations.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_form_field.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_form_scaffold.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_mark.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_otp_field.dart';

Widget _host(
  Widget child, {
  Brightness brightness = Brightness.dark,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const <Locale>[Locale('en'), Locale('fr')],
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: brightness == Brightness.dark
        ? VinkolTheme.dark()
        : VinkolTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: child,
    ),
  );
}

void main() {
  group('the form archetype', () {
    testWidgets('the primary action is anchored, not scrolled', (tester) async {
      var submitted = false;
      await tester.pumpWidget(_host(
        VinkolFormScaffold(
          fields: <Widget>[
            for (var i = 0; i < 20; i++)
              VinkolFormField(
                  label: 'Field $i', controller: TextEditingController()),
          ],
          primaryAction: VinkolPrimaryButton(
            label: 'Continue',
            onPressed: () => submitted = true,
          ),
        ),
      ));

      // Twenty fields is well past a screen; the dock must still be tappable without
      // scrolling, which is the whole point of anchoring it.
      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      expect(submitted, isTrue);
    });

    testWidgets('a disabled primary action stays visible', (tester) async {
      await tester.pumpWidget(_host(
        const VinkolFormScaffold(
          fields: <Widget>[],
          primaryAction: VinkolPrimaryButton(label: 'Log in'),
        ),
      ));
      // Hiding it would leave the user with no idea what the screen is for.
      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('a loading action shows a spinner and blocks the tap',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(
        VinkolFormScaffold(
          fields: const <Widget>[],
          primaryAction: VinkolPrimaryButton(
            label: 'Log in',
            loading: true,
            onPressed: () => taps++,
          ),
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(VinkolPrimaryButton));
      expect(taps, 0);
    });

    testWidgets('a long label wraps rather than clipping', (tester) async {
      await tester.pumpWidget(_host(
        VinkolFormScaffold(
          fields: const <Widget>[],
          primaryAction: VinkolPrimaryButton(
            label: 'Réinitialiser le mot de passe et continuer',
            onPressed: () {},
          ),
        ),
      ));
      final text = tester.widget<Text>(
        find.text('Réinitialiser le mot de passe et continuer'),
      );
      // Two lines, because French runs ~40% longer than English.
      expect(text.maxLines, 2);
      expect(tester.takeException(), isNull);
    });
  });

  group('the OTP field', () {
    testWidgets('renders one cell per digit and fills them in order',
        (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_host(
        Scaffold(body: VinkolOtpField(controller: controller, length: 4)),
      ));
      controller.text = '47';
      await tester.pump();
      expect(find.text('4'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('onCompleted fires exactly when the last digit lands',
        (tester) async {
      final controller = TextEditingController();
      final completed = <String>[];
      await tester.pumpWidget(_host(
        Scaffold(
          body: VinkolOtpField(
            controller: controller,
            length: 4,
            onCompleted: completed.add,
          ),
        ),
      ));
      controller.text = '471';
      await tester.pump();
      expect(completed, isEmpty);
      controller.text = '4718';
      await tester.pump();
      expect(completed, <String>['4718']);
    });

    testWidgets('an error is stated in words', (tester) async {
      await tester.pumpWidget(_host(
        Scaffold(
          body: VinkolOtpField(
            controller: TextEditingController(),
            length: 4,
            error: 'Enter all 4 digits to continue.',
          ),
        ),
      ));
      expect(find.text('Enter all 4 digits to continue.'), findsOneWidget);
    });

    testWidgets('it accepts a pasted one-time code', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_host(
        Scaffold(body: VinkolOtpField(controller: controller, length: 6)),
      ));
      final field = tester.widget<TextField>(find.byType(TextField));
      // A single field, so autofill can drop the whole code in at once. Per-digit fields
      // break paste and fight the platform's code suggestion.
      expect(field.autofillHints, contains(AutofillHints.oneTimeCode));
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('the mark is drawn, not an asset', () {
    testWidgets('it renders at any size in both themes', (tester) async {
      for (final brightness in Brightness.values) {
        for (final height in <double>[36, 76, 140]) {
          await tester.pumpWidget(_host(
            Scaffold(body: Center(child: VinkolMark(height: height))),
            brightness: brightness,
          ));
          expect(tester.takeException(), isNull);
        }
      }
      // No Image widget anywhere — the old splash and auth screens both loaded a PNG that
      // could not recolour for dark mode.
      expect(find.byType(Image), findsNothing);
    });
  });

  group('layout survives a larger text scale', () {
    testWidgets('the form archetype holds at 1.3x and 2.0x', (tester) async {
      for (final scale in <double>[1.3, 2.0]) {
        await tester.pumpWidget(_host(
          VinkolFormScaffold(
            fields: <Widget>[
              VinkolFormField(
                label: 'Email address',
                controller: TextEditingController(),
                error: 'That address is not on any account.',
              ),
            ],
            primaryAction:
                VinkolPrimaryButton(label: 'Send code', onPressed: () {}),
          ),
          textScale: scale,
        ));
        expect(tester.takeException(), isNull,
            reason: 'form overflowed at ${scale}x text scale');
      }
    });
  });
}
