import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class LocalCacheImpl implements LocalCache {
  static const _tokenKey = 'userToken';
  static const _userDataKey = 'userData';
  static const _onBoardedKey = 'isOnboarded';
  static const _authenticatedKey = 'isAuthenticated';
  static const _guestModeKey = 'guestModeKey';
  static const _encryptionKeyName = 'hive_encryption_key';
  static const _keyHashName = 'hive_key_hash'; // NEW: To verify key integrity

  late final _log = appLogger(LocalCacheImpl);

  late Box _secureBox;
  late Box _settingsBox;
  final _keyStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true, // NEW: Reset on errors
    ),
  );

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _log.i('Initializing Hive storage...');
      await Hive.initFlutter();

      // Open settings box first (unencrypted) to store key hash
      _settingsBox = await Hive.openBox('settings_storage');

      final encryptionKey = await _getOrCreateEncryptionKey();

      // Try to open the secure box, delete if corrupted
      try {
        _secureBox = await Hive.openBox(
          'secure_storage',
          encryptionCipher: HiveAesCipher(encryptionKey),
        );
        _log.i('Secure box opened successfully');
      } catch (e) {
        _log.w('Failed to open secure box (likely corrupted): $e');
        _log.i('Deleting corrupted secure box...');

        // Delete the corrupted box
        await Hive.deleteBoxFromDisk('secure_storage');

        // Try opening again
        _secureBox = await Hive.openBox(
          'secure_storage',
          encryptionCipher: HiveAesCipher(encryptionKey),
        );
        _log.i('Secure box recreated successfully');
      }

      _log.i('Secure box keys: ${_secureBox.keys.toList()}');
      _log.i('Settings box keys: ${_settingsBox.keys.toList()}');

      _initialized = true;
      _log.i('Hive storage initialized successfully');
    } catch (e) {
      _log.e('Error initializing Hive: $e');
      rethrow;
    }
  }

  Future<List<int>> _getOrCreateEncryptionKey() async {
    try {
      // Get stored key hash from settings box
      final storedHash = _settingsBox.get(_keyHashName) as String?;

      // Try to read existing key from secure storage
      String? existingKeyString;
      try {
        existingKeyString = await _keyStorage.read(key: _encryptionKeyName);
      } catch (e) {
        _log.w('Failed to read from secure storage: $e');
      }

      // If we have both key and hash, verify they match
      if (existingKeyString != null && storedHash != null) {
        try {
          final key = base64Url.decode(existingKeyString);
          final keyHash = sha256.convert(key).toString();

          if (keyHash == storedHash) {
            _log.i('Retrieved existing encryption key (hash verified)');
            return key;
          } else {
            _log.w('Key hash mismatch! Key may be corrupted.');
          }
        } catch (e) {
          _log.w('Failed to decode existing key: $e');
        }
      }
    } catch (e) {
      _log.w('Error retrieving encryption key: $e');
    }

    // Generate new key
    _log.i('Generating new encryption key');
    final key = Hive.generateSecureKey();
    final keyHash = sha256.convert(key).toString();

    try {
      // Store key in secure storage
      await _keyStorage.write(
        key: _encryptionKeyName,
        value: base64UrlEncode(key),
      );

      // Store hash in settings box for verification
      await _settingsBox.put(_keyHashName, keyHash);

      // Verify it was written
      final verification = await _keyStorage.read(key: _encryptionKeyName);
      if (verification != null) {
        _log.i('Encryption key and hash stored successfully');
      } else {
        _log.e('CRITICAL: Failed to store encryption key!');
      }
    } catch (e) {
      _log.e('Failed to store encryption key: $e');
    }

    return key;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw Exception('LocalCache not initialized. Call initialize() first.');
    }
  }

  @override
  Future<void> onBoarded() async {
    try {
      _ensureInitialized();
      await _settingsBox.put(_onBoardedKey, true);
      _log.i('Onboarding completed and saved');
    } catch (e) {
      _log.e('Error saving onboarding status: $e');
    }
  }

  @override
  Future<bool> isOnBoarded() async {
    try {
      _ensureInitialized();
      final value = _settingsBox.get(_onBoardedKey, defaultValue: false);
      return value as bool;
    } catch (e) {
      _log.e('Error fetching onboarding status: $e');
      return false;
    }
  }

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

  @override
  Future<void> deleteToken() async {
    try {
      _ensureInitialized();
      await _secureBox.delete(_tokenKey);
      _log.i('Token deleted');
    } catch (e) {
      _log.e('Error deleting token: $e');
    }
  }

  @override
  Object? getFromLocalCache(String key) {
    try {
      _ensureInitialized();
      if (_settingsBox.containsKey(key)) {
        final value = _settingsBox.get(key);
        _log.i('Retrieved from settings cache - key: $key, value: $value');
        return value;
      } else if (_secureBox.containsKey(key)) {
        final value = _secureBox.get(key);
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
  String? getToken() {
    try {
      _ensureInitialized();
      final token = _secureBox.get(_tokenKey) as String?;
      _log.i('Token retrieved: ${token != null ? 'exists' : 'null'}');
      return token;
    } catch (e) {
      _log.e('Error retrieving token: $e');
      return null;
    }
  }

  @override
  Future<void> removeFromLocalCache(String key) async {
    try {
      _ensureInitialized();
      await _settingsBox.delete(key);
      await _secureBox.delete(key);
      _log.i('Removed key from cache: $key');
    } catch (e) {
      _log.e('Error removing from cache - key: $key, error: $e');
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      _ensureInitialized();
      await _secureBox.put(_tokenKey, token);
      _log.i('Token saved securely');
    } catch (e) {
      _log.e('Error saving token: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveToLocalCache({required String key, required value}) async {
    _log.i('Data being saved: key: $key, value: $value');

    try {
      _ensureInitialized();

      final isSensitive = _isSensitiveKey(key);
      final targetBox = isSensitive ? _secureBox : _settingsBox;

      if (value is String ||
          value is bool ||
          value is int ||
          value is double ||
          value is List<String>) {
        await targetBox.put(key, value);
      } else if (value is Map) {
        await targetBox.put(key, json.encode(value));
      } else {
        throw Exception('Unsupported value type: ${value.runtimeType}');
      }

      _log.i(
          'Data saved successfully: key: $key in ${isSensitive ? "secure" : "settings"} box');
    } catch (e) {
      _log.e('Error saving data: key: $key, error: $e');
      rethrow;
    }
  }

  bool _isSensitiveKey(String key) {
    return key == _tokenKey ||
        key == _userDataKey ||
        key.toLowerCase().contains('token') ||
        key.toLowerCase().contains('password') ||
        key.toLowerCase().contains('secret');
  }

  @override
  Future<void> clearCache() async {
    try {
      _ensureInitialized();
      await _secureBox.clear();
      await _settingsBox.clear();

      // Also clear the encryption key
      try {
        await _keyStorage.delete(key: _encryptionKeyName);
        _log.i('Encryption key deleted from secure storage');
      } catch (e) {
        _log.w('Failed to delete encryption key: $e');
      }

      _log.i('All cache cleared');
    } catch (e) {
      _log.e('Error clearing cache: $e');
    }
  }

  @override
  Map<String, dynamic>? getUserData() {
    try {
      _ensureInitialized();
      final data = _secureBox.get(_userDataKey) as String?;
      if (data == null) return null;
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      _log.e('Error getting user data: $e');
      return null;
    }
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> json) async {
    try {
      _ensureInitialized();
      await _secureBox.put(_userDataKey, jsonEncode(json));
      _log.i('User data saved');
    } catch (e) {
      _log.e('Error saving user data: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _secureBox.close();
    await _settingsBox.close();
    _log.i('Hive boxes closed');
  }
}
