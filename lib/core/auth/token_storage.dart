import 'package:flutter/foundation.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction over token storage. UI must NEVER use this or [TokenManager]'s storage directly.
/// Web → localStorage (via SharedPreferences). Mobile/iOS → secure storage.
abstract class TokenStorage {
  Future<String?> get(String key);
  Future<void> set(String key, String value);
  Future<void> remove(String key);
}

/// Web: uses SharedPreferences (localStorage). Mobile: uses FlutterSecureStorage.
TokenStorage createTokenStorage() {
  if (kIsWeb) {
    return _SharedPrefsTokenStorage();
  }
  return _SecureTokenStorage();
}

class _SharedPrefsTokenStorage implements TokenStorage {
  static SharedPreferences? _prefs;
  static Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<String?> get(String key) async {
    return (await _instance).getString(key);
  }

  @override
  Future<void> set(String key, String value) async {
    await (await _instance).setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await (await _instance).remove(key);
  }
}

class _SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<String?> get(String key) async => _storage.read(key: key);

  @override
  Future<void> set(String key, String value) async =>
      _storage.write(key: key, value: value);

  @override
  Future<void> remove(String key) async => _storage.delete(key: key);
}
