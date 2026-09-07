/// Telling a connection failure apart from a server one.
///
/// The two deserve different screens: an offline failure is the user's to fix and retrying
/// without a network cannot work, while a server failure is worth stating and retrying. Both
/// Records and Wallet ask the same question, so they ask it in one place.
library;

/// Whether a failure message reads as a connection problem rather than a server one.
///
/// Crude, because the failure arrives as a string. A typed failure from the network layer
/// would be better and is worth doing when that layer is next touched.
bool looksOffline(Object? failure) {
  final String m = failure?.toString().toLowerCase() ?? '';
  return m.contains('socket') ||
      m.contains('network') ||
      m.contains('connection') ||
      m.contains('internet') ||
      m.contains('timeout');
}
