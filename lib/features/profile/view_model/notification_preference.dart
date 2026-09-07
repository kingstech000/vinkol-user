/// The one notification preference the app can honestly offer.
///
/// There is no notification-preference endpoint and no notification store
/// (`.claude/design/08-backend-gaps.md`): Vinkol sends FCM push when an order changes status
/// and keeps no history. So there is exactly one switch, and it does the only thing that
/// actually works without a server — it drops this device's FCM registration, so there is
/// nothing for the server to push to. Switching it back on re-registers.
///
/// The choice is cached locally and honoured by [AuthService.sendFcmTokenToBackend], which
/// runs on every sign-in; without that guard the next login would silently turn push back on.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/services/notification_service.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/features/auth/data/auth_service.dart';

class NotificationPreferenceNotifier extends StateNotifier<bool> {
  NotificationPreferenceNotifier(this._ref) : super(_restore());

  final Ref _ref;
  final AppLogger _logger = const AppLogger(NotificationPreferenceNotifier);

  /// Defaults to on. A user who has never opened this screen is registered for push today,
  /// and the stored value must describe that rather than contradict it.
  static bool _restore() {
    if (!locator.isRegistered<LocalCache>()) return true;
    try {
      final stored = locator<LocalCache>()
          .getFromLocalCache(NotificationService.pushEnabledCacheKey);
      return stored is bool ? stored : true;
    } catch (_) {
      return true;
    }
  }

  /// True while the registration change is in flight. The switch stays interactive; the row
  /// just says what is happening.
  bool get busy => _busy;
  bool _busy = false;

  Future<void> setEnabled(bool enabled) async {
    if (enabled == state || _busy) return;

    // Optimistic: the switch moves under the thumb, and the preference is what the app
    // behaves on even if the network call for re-registration fails.
    state = enabled;
    _busy = true;
    await _persist(enabled);

    try {
      if (enabled) {
        await _ref.read(authServiceProvider).sendFcmTokenToBackend();
      } else {
        await NotificationService.instance.deleteToken();
      }
    } catch (e) {
      _logger.e('Failed to apply notification preference: $e');
    } finally {
      _busy = false;
    }
  }

  Future<void> _persist(bool enabled) async {
    if (!locator.isRegistered<LocalCache>()) return;
    try {
      await locator<LocalCache>().saveToLocalCache(
        key: NotificationService.pushEnabledCacheKey,
        value: enabled,
      );
    } catch (e) {
      _logger.e('Failed to persist notification preference: $e');
    }
  }
}

final notificationPreferenceProvider =
    StateNotifierProvider<NotificationPreferenceNotifier, bool>(
  NotificationPreferenceNotifier.new,
);
