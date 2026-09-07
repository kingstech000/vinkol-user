/// The Vinkol market layer. Import this rather than the individual files.
///
/// One global brand, configurable markets (`.claude/design/03-globalization-gaps.md`). A
/// screen never asks what country it is in — it asks the market a question. **A screen that
/// branches on country is a bug**; if it needs to know where it is, the market is missing a
/// field, so add the field.
library;

export 'locale_provider.dart';
export 'market_format.dart';
export 'market_provider.dart';
export 'market_scope.dart';
export 'markets.dart';
export 'models.dart';
export 'regions.dart';
