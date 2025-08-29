import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/app_logger.dart';

class LocalCacheImpl implements LocalCache {
  static const _tokenKey = 'userToken';
  static const _userDataKey = 'userData';
  static const _onBoardedKey = 'true';
  static const _balanceKey = 'balanceKey';
  static const _guestModeKey = 'guestModeKey';
  late final _log = appLogger(LocalCacheImpl);

  late SharedPreferences _sharedPreferences;

  LocalCacheImpl({
    required SharedPreferences sharedPreferences,
  }) {
    _sharedPreferences = sharedPreferences;
  }

  @override
  Future<void> onBoarded() async {
    try {
      // Saving that the user has completed onboarding
      await saveToLocalCache(key: _onBoardedKey, value: true);
      _log.i('Onboarding completed and saved');
    } catch (e) {
      _log.i('Error saving onboarding status: $e');
    }
  }

  @override
  Future<bool> isOnBoarded() async {
    try {
      final value = getFromLocalCache(_onBoardedKey) as bool?;
      return value ?? false;
    } catch (e) {
      _log.e('Error fetching onboarding status: $e');
      return false;
    }
  }

  @override
  Future<void> toggleBalanceVisibility() async {
    try {
      final isVisible = isBalanceVisible();
      await saveToLocalCache(key: _balanceKey, value: !isVisible);
      _log.i('Toggled Balance');
    } catch (e) {
      _log.i('Error toggling balance: $e');
    }
  }

  @override
  bool isBalanceVisible() {
    try {
      final value = getFromLocalCache(_balanceKey) as bool?;
      return value ?? false;
    } catch (e) {
      _log.e('Error  fetching balance status: $e');
      return false;
    }
  }

  // GUEST MODE METHODS
  @override
  Future<void> setGuestMode(bool isGuest) async {
    try {
      await saveToLocalCache(key: _guestModeKey, value: isGuest);
      _log.i('Guest mode set to: $isGuest');
    } catch (e) {
      _log.e('Error setting guest mode: $e');
    }
  }

  @override
  bool isGuestMode() {
    try {
      final value = getFromLocalCache(_guestModeKey) as bool?;
      return value ?? false;
    } catch (e) {
      _log.e('Error fetching guest mode status: $e');
      return false;
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await removeFromLocalCache(_tokenKey);
    } catch (e) {
      _log.i(e);
    }
  }

  @override
  Object? getFromLocalCache(String key) {
    try {
      return _sharedPreferences.get(key);
    } catch (e) {
      _log.i(e);
      return null;
    }
  }

  @override
  String? getToken() {
    return getFromLocalCache(_tokenKey) as String?;
  }

  @override
  Future<void> removeFromLocalCache(String key) async {
    await _sharedPreferences.remove(key);
  }

  @override
  Future<void> saveToken(String token) async {
    saveToLocalCache(key: _tokenKey, value: token);
  }

  @override
  Future<void> saveToLocalCache({required String key, required value}) async {
    _log.i('Data being saved: key: $key, value: $value');

    if (value is String) {
      await _sharedPreferences.setString(key, value);
    }
    if (value is bool) {
      await _sharedPreferences.setBool(key, value);
    }
    if (value is int) {
      await _sharedPreferences.setInt(key, value);
    }
    if (value is double) {
      await _sharedPreferences.setDouble(key, value);
    }
    if (value is List<String>) {
      await _sharedPreferences.setStringList(key, value);
    }
    if (value is Map) {
      await _sharedPreferences.setString(key, json.encode(value));
    }
  }

  @override
  Future<void> clearCache() async {
    await _sharedPreferences.clear();
  }

  @override
  Map<String, dynamic>? getUserData() {
    try {
      final data = getFromLocalCache(_userDataKey) as String;
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> json) async {
    await saveToLocalCache(
      key: _userDataKey,
      value: json,
    );
  }
}
