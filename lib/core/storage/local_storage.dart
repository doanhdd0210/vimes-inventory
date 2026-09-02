import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/typedefs.dart';

/// Key/value store for non-sensitive app preferences (theme mode, onboarding
/// seen, last-used flavor…). Backed by `shared_preferences`.
abstract class LocalStorage {
  Future<void> setString(String key, String value);
  String? getString(String key);

  Future<void> setBool(String key, bool value);
  bool? getBool(String key);

  Future<void> setInt(String key, int value);
  int? getInt(String key);

  Future<void> setJson(String key, DataMap value);
  DataMap? getJson(String key);

  Future<void> remove(String key);
  Future<void> clear();
}

class SharedPrefsLocalStorage implements LocalStorage {
  SharedPrefsLocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPrefsLocalStorage> create() async =>
      SharedPrefsLocalStorage(await SharedPreferences.getInstance());

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  DataMap? getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  @override
  Future<void> setJson(String key, DataMap value) =>
      _prefs.setString(key, jsonEncode(value));

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();
}

/// Well-known preference keys.
class StorageKeys {
  const StorageKeys._();

  static const String themeMode = 'pref.theme_mode';
  static const String onboardingSeen = 'pref.onboarding_seen';
  static const String locale = 'pref.locale';
  static const String lastFlavor = 'pref.last_flavor';

  // Secure keys
  static const String authToken = 'secure.auth_token';
  static const String refreshToken = 'secure.refresh_token';
}
