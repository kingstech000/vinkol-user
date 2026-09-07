import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/market/markets.dart';
import 'package:starter_codes/core/market/models.dart';

/// The market layer is imported file-by-file rather than through the barrel: these assertions
/// must not depend on Riverpod, the locator or the network layer.
Map<String, String> _messages(String path) {
  final raw = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return <String, String>{
    for (final e in raw.entries)
      if (!e.key.startsWith('@')) e.key: e.value as String,
  };
}

void main() {
  final en = _messages('lib/l10n/app_en.arb');
  final fr = _messages('lib/l10n/app_fr.arb');

  group('translation coverage', () {
    // Quebec's Charter of the French Language makes an untranslated string a compliance
    // problem, not a cosmetic one. A key that exists in English and not in French silently
    // falls back to English, so it has to fail here instead.
    test('every English message has a French translation', () {
      expect(en.keys.toSet().difference(fr.keys.toSet()), isEmpty,
          reason: 'untranslated keys');
      expect(fr.keys.toSet().difference(en.keys.toSet()), isEmpty,
          reason: 'French keys with no English source');
    });

    // Words that are genuinely the same in both languages. Listing them explicitly is the
    // point: a new identical string has to be justified here rather than slipping through
    // as an untranslated one.
    // 'storeTimesPrice' is punctuation and two placeholders — "2 × \$4,500" reads the
    // same in both languages, and translating the multiplication sign would be wrong.
    const identicalInBoth = <String>{
      'storeTotal',
      'storeDescription',
      'storeTimesPrice',
    };

    test('no French message was left as its English source', () {
      // Short symbols legitimately match across both languages ('OK', 'or'/'ou'); anything
      // longer that is identical and not on the list above is untranslated.
      final untranslated = <String>[
        for (final k in en.keys)
          if (en[k] == fr[k] &&
              en[k]!.trim().length > 4 &&
              !identicalInBoth.contains(k))
            k,
      ];
      expect(untranslated, isEmpty);
    });

    test('placeholders and line breaks survive translation', () {
      for (final k in en.keys) {
        expect(
            RegExp(r'\{(\w+)\}')
                .allMatches(fr[k]!)
                .map((m) => m.group(1))
                .toSet(),
            RegExp(r'\{(\w+)\}')
                .allMatches(en[k]!)
                .map((m) => m.group(1))
                .toSet(),
            reason: '$k: placeholder set differs');
        expect('\n'.allMatches(fr[k]!).length, '\n'.allMatches(en[k]!).length,
            reason:
                '$k: hard line-break count differs, which breaks the layout it was '
                'written for');
      }
    });
  });

  group('locale is market-owned', () {
    test('Nigeria ships English only; Canada ships English and Français', () {
      expect(Markets.nigeria.languageCodes, <String>['en']);
      expect(Markets.canada.languageCodes, <String>['en', 'fr']);
    });

    test('a market never offers a language it has no copy for', () {
      expect(Markets.nigeria.offersLanguage('fr'), isFalse);
      expect(Markets.canada.offersLanguage('fr'), isTrue);
      expect(Markets.canada.offersLanguage(null), isFalse);
      expect(Markets.canada.offersLanguage('de'), isFalse);
    });

    test('languages are named in the language they are', () {
      final fr = Markets.canada.languages
          .firstWhere((MarketLanguage l) => l.code == 'fr');
      expect(fr.nativeName, 'Français');
    });

    test('the first language is the market default', () {
      expect(Markets.canada.languages.first.code, 'en');
    });
  });

  group('layout budget', () {
    // The design rule is "assume +40% text length". This measures the actual growth so the
    // number in the brief is a fact about this app's copy rather than a guess.
    test('French growth is within the assumed budget for short labels', () {
      final worst = <String, double>{};
      for (final k in en.keys) {
        final e = en[k]!.trim().length, f = fr[k]!.trim().length;
        if (e < 3) continue;
        worst[k] = f / e;
      }
      final mean = worst.values.reduce((a, b) => a + b) / worst.length;
      // Not an assertion about any one string — single words can double ("Skip"/"Passer" is
      // fine, "or"/"ou" is not). The aggregate is what layout must survive.
      expect(mean, lessThan(1.4),
          reason:
              'average French/English length ratio ${mean.toStringAsFixed(3)}');
    });
  });
}
