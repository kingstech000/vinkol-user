/// Access to the app's translated strings.
///
/// Quebec's Charter of the French Language makes French a legal requirement for
/// consumer-facing commercial content (`.claude/design/08-backend-gaps.md`), so this is
/// compliance infrastructure, not a convenience.
///
/// Two accessors, because the app has two kinds of caller:
///   `context.l10n`  — the default. Rebuilds correctly when the locale changes.
///   `L10n.current`  — for view models and helpers that have no [BuildContext]. Resolved
///                     through the root navigator key.
library;

import 'package:flutter/widgets.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/l10n/app_localizations.dart';
import 'package:starter_codes/l10n/app_localizations_en.dart';

export 'package:starter_codes/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  /// The active translations. Throws if the widget is not under a [Localizations] scope,
  /// which is a wiring bug worth failing loudly on rather than papering over with English.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

abstract final class L10n {
  /// Translations for callers with no [BuildContext] — view models, services, and the
  /// helper methods that build a widget without taking a context parameter.
  ///
  /// Falls back to English when the navigator has no context yet (a message emitted before
  /// the first frame). That fallback is a real gap in a French market, so prefer
  /// `context.l10n` wherever a context is available and treat a call to this from a widget
  /// as something to fix.
  static AppLocalizations get current {
    final context = NavigationService.instance.navigatorKey.currentContext;
    if (context == null) return AppLocalizationsEn();
    return AppLocalizations.of(context);
  }
}
