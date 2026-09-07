import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class LocalCacheImpl implements LocalCache {
  static const _tokenKey = 'userToken';
  static const _userDataKey = 'userData';
  static const _authenticatedKey = 'isAuthenticated';
  static const _guestModeKey = 'guestModeKey';

  // Legacy keys for migration from old encrypted Hive box
  static const _legacyEncryptionKeyName = 'hive_encryption_key';
  static const _legacyKeyHashName = 'hive_key_hash';

  late final _log = appLogger(LocalCacheImpl);

  // In-memory cache for sync access to sensitive data
  String? _cachedToken;
  Map<String, dynamic>? _cachedUserData;
  final Map<String, String> _secureCache = {};

  // Unencrypted Hive box for non-sensitive flags and settings
  late Box _settingsBox;

  // FlutterSecureStorage for sensitive data (token, user data)
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _log.i('Initializing storage...');
      await Hive.initFlutter();

      // Open unencrypted Hive box for non-sensitive flags
      _settingsBox = await Hive.openBox('settings_storage');

      // Load sensitive data from FlutterSecureStorage into memory
      await _loadSecureData();

      // Migrate from old encrypted Hive box if it exists
      await _migrateFromLegacyStorage();

      _log.i('Settings box keys: ${_settingsBox.keys.toList()}');

      _initialized = true;
      _log.i('Storage initialized successfully');
    } catch (e) {
      _log.e('Error initializing storage: $e');
      rethrow;
    }
  }

  /// Loads sensitive data from FlutterSecureStorage into in-memory cache
  /// so sync getters (getToken, getUserData) continue to work.
  Future<void> _loadSecureData() async {
    try {
      _cachedToken = await _secureStorage.read(key: _tokenKey);

      final userDataStr = await _secureStorage.read(key: _userDataKey);
      if (userDataStr != null) {
        try {
          _cachedUserData = jsonDecode(userDataStr) as Map<String, dynamic>;
        } catch (e) {
          _log.w('Failed to decode cached user data: $e');
          _cachedUserData = null;
        }
      }

      _log.i(
          'Secure data loaded: token=${_cachedToken != null && _cachedToken!.isNotEmpty ? "exists" : "null"}');
    } catch (e) {
      _log.w('Failed to load secure data from FlutterSecureStorage: $e');
      _cachedToken = null;
      _cachedUserData = null;
    }
  }

  /// Migrates data from the old encrypted Hive box to FlutterSecureStorage,
  /// then deletes the legacy box and encryption key.
  Future<void> _migrateFromLegacyStorage() async {
    try {
      if (!await Hive.boxExists('secure_storage')) return;

      _log.i('Found legacy encrypted Hive box, attempting migration...');

      String? oldKeyString;
      try {
        oldKeyString = await _secureStorage.read(key: _legacyEncryptionKeyName);
      } catch (e) {
        _log.w('Cannot read legacy encryption key: $e');
      }

      // Only attempt migration if we have the old key and don't already
      // have a token in the new storage
      if (oldKeyString != null &&
          (_cachedToken == null || _cachedToken!.isEmpty)) {
        try {
          final oldKey = base64Url.decode(oldKeyString);
          final oldBox = await Hive.openBox(
            'secure_storage',
            encryptionCipher: HiveAesCipher(oldKey),
          );

          // Migrate token
          final oldToken = oldBox.get(_tokenKey) as String?;
          if (oldToken != null && oldToken.isNotEmpty) {
            await saveToken(oldToken);
            _log.i('Migrated token from legacy storage');
          }

          // Migrate user data
          final oldUserData = oldBox.get(_userDataKey) as String?;
          if (oldUserData != null) {
            await _secureStorage.write(key: _userDataKey, value: oldUserData);
            try {
              _cachedUserData = jsonDecode(oldUserData) as Map<String, dynamic>;
            } catch (_) {}
            _log.i('Migrated user data from legacy storage');
          }

          await oldBox.close();
        } catch (e) {
          _log.w('Failed to open/migrate legacy box (likely corrupted): $e');
        }
      }

      // Clean up legacy storage regardless of migration success
      try {
        if (Hive.isBoxOpen('secure_storage')) {
          await Hive.box('secure_storage').close();
        }
        await Hive.deleteBoxFromDisk('secure_storage');
        await _secureStorage.delete(key: _legacyEncryptionKeyName);
        await _settingsBox.delete(_legacyKeyHashName);
        _log.i('Legacy encrypted storage cleaned up');
      } catch (e) {
        _log.w('Failed to clean up legacy storage: $e');
      }
    } catch (e) {
      _log.w('Migration check failed: $e');
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw Exception('LocalCache not initialized. Call initialize() first.');
    }
  }

  // ==================== Token ====================

  @override
  String? getToken() {
    try {
      _ensureInitialized();
      _log.i(
          'Token retrieved: ${_cachedToken != null && _cachedToken!.isNotEmpty ? 'exists' : 'null'}');
      return _cachedToken;
    } catch (e) {
      _log.e('Error retrieving token: $e');
      return null;
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      _ensureInitialized();
      await _secureStorage.write(key: _tokenKey, value: token);
      _cachedToken = token;
      _log.i('Token saved securely');
    } catch (e) {
      _log.e('Error saving token: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      _ensureInitialized();
      await _secureStorage.delete(key: _tokenKey);
      _cachedToken = null;
      _log.i('Token deleted');
    } catch (e) {
      _log.e('Error deleting token: $e');
    }
  }

  // ==================== User Data ====================

  @override
  Map<String, dynamic>? getUserData() {
    try {
      _ensureInitialized();
      return _cachedUserData;
    } catch (e) {
      _log.e('Error getting user data: $e');
      return null;
    }
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> json) async {
    try {
      _ensureInitialized();
      final encoded = jsonEncode(json);
      await _secureStorage.write(key: _userDataKey, value: encoded);
      _cachedUserData = json;
      _log.i('User data saved');
    } catch (e) {
      _log.e('Error saving user data: $e');
      rethrow;
    }
  }

  // ==================== Authentication ====================

  @override
  Future<void> authenticated() async {
    try {
      _ensureInitialized();
      await _settingsBox.put(_authenticatedKey, true);
      _log.i('Authentication status saved');
    } catch (e) {
      _log.e('Error saving authentication status: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      _ensureInitialized();
      final value = _settingsBox.get(_authenticatedKey, defaultValue: false);
      return value as bool;
    } catch (e) {
      _log.e('Error fetching authentication status: $e');
      return false;
    }
  }

  // ==================== Guest Mode ====================

  @override
  Future<void> setGuestMode(bool isGuest) async {
    try {
      _ensureInitialized();
      await _settingsBox.put(_guestModeKey, isGuest);
      _log.i('Guest mode set to: $isGuest');
    } catch (e) {
      _log.e('Error setting guest mode: $e');
    }
  }

  @override
  bool isGuestMode() {
    try {
      _ensureInitialized();
      final value = _settingsBox.get(_guestModeKey, defaultValue: false);
      return value as bool;
    } catch (e) {
      _log.e('Error fetching guest mode status: $e');
      return false;
    }
  }

  // ==================== Generic Cache ====================

  @override
  Future<void> saveToLocalCache(
      {required String key, required dynamic value}) async {
    _log.i('Data being saved: key: $key');

    try {
      _ensureInitialized();

      if (_isSensitiveKey(key)) {
        // Sensitive data goes to FlutterSecureStorage
        String stringValue;
        if (value is String) {
          stringValue = value;
        } else if (value is Map || value is List) {
          stringValue = jsonEncode(value);
        } else {
          stringValue = value.toString();
        }
        await _secureStorage.write(key: key, value: stringValue);
        _secureCache[key] = stringValue;
        _log.i('Data saved to secure storage: key: $key');
      } else {
        // Non-sensitive data goes to Hive settings box
        if (value is String ||
            value is bool ||
            value is int ||
            value is double ||
            value is List<String>) {
          await _settingsBox.put(key, value);
        } else if (value is Map) {
          await _settingsBox.put(key, jsonEncode(value));
        } else {
          throw Exception('Unsupported value type: ${value.runtimeType}');
        }
        _log.i('Data saved to settings box: key: $key');
      }
    } catch (e) {
      _log.e('Error saving data: key: $key, error: $e');
      rethrow;
    }
  }

  @override
  Object? getFromLocalCache(String key) {
    try {
      _ensureInitialized();

      // Check settings box first (non-sensitive)
      if (_settingsBox.containsKey(key)) {
        final value = _settingsBox.get(key);
        _log.i('Retrieved from settings cache - key: $key');
        return value;
      }

      // Check in-memory secure cache
      if (_secureCache.containsKey(key)) {
        final value = _secureCache[key];
        _log.i('Retrieved from secure cache - key: $key');
        return value;
      }

      return null;
    } catch (e) {
      _log.e('Error retrieving from cache - key: $key, error: $e');
      return null;
    }
  }

  @override
  Future<void> removeFromLocalCache(String key) async {
    try {
      _ensureInitialized();
      await _settingsBox.delete(key);
      if (_isSensitiveKey(key)) {
        await _secureStorage.delete(key: key);
        _secureCache.remove(key);
      }
      _log.i('Removed key from cache: $key');
    } catch (e) {
      _log.e('Error removing from cache - key: $key, error: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      _ensureInitialized();
      await _settingsBox.clear();

      // Clear all sensitive data
      await _secureStorage.deleteAll();
      _cachedToken = null;
      _cachedUserData = null;
      _secureCache.clear();

      _log.i('All cache cleared');
    } catch (e) {
      _log.e('Error clearing cache: $e');
    }
  }

  // ==================== Helpers ====================

  bool _isSensitiveKey(String key) {
    return key == _tokenKey ||
        key == _userDataKey ||
        key.toLowerCase().contains('token') ||
        key.toLowerCase().contains('password') ||
        key.toLowerCase().contains('secret');
  }
}
