import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/locator.dart';

/// What the customer has asked for, as far as the client can actually deliver
/// it.
///
/// There is no notification-preferences endpoint, so nothing here is a server
/// setting and nothing here claims to be. What the app genuinely controls is
/// how it renders an alert that arrives while it is running; whether the device
/// receives pushes at all is an operating-system permission, read but never
/// written from here.
class NotificationPreferences {
  const NotificationPreferences({required this.soundAndVibration});

  /// Play a sound and vibrate for alerts the app draws itself.
  final bool soundAndVibration;

  NotificationPreferences copyWith({bool? soundAndVibration}) {
    return NotificationPreferences(
      soundAndVibration: soundAndVibration ?? this.soundAndVibration,
    );
  }
}

/// The cache key, and the one place that decides the default.
const String _kSoundKey = 'notification_sound_and_vibration';

/// Reads the sound preference without Riverpod.
///
/// [NotificationService.showNotification] runs in a background isolate for
/// pushes that arrive while the app is terminated, where neither the provider
/// container nor the service locator has been set up. Anything thrown there is
/// swallowed and the preference defaults to on, which is what the operating
/// system would have done anyway.
bool notificationSoundEnabled() {
  try {
    final value = locator<LocalCache>().getFromLocalCache(_kSoundKey);
    return value is bool ? value : true;
  } catch (_) {
    return true;
  }
}

class NotificationPreferencesNotifier
    extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier(this._cache)
      : super(NotificationPreferences(
          soundAndVibration: notificationSoundEnabled(),
        ));

  final LocalCache _cache;

  Future<void> setSoundAndVibration(bool enabled) async {
    state = state.copyWith(soundAndVibration: enabled);
    await _cache.saveToLocalCache(key: _kSoundKey, value: enabled);
  }
}

final notificationPreferencesProvider = StateNotifierProvider<
    NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier(locator<LocalCache>());
});

/// Whether this device is allowed to receive pushes at all.
///
/// Owned by the operating system. The app can ask once; after that only the
/// phone's own Settings app can change it, so this is read-only here.
final pushAuthorizationProvider =
    FutureProvider<AuthorizationStatus>((ref) async {
  final settings = await FirebaseMessaging.instance.getNotificationSettings();
  return settings.authorizationStatus;
});
