import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage_service.dart';

/// SharedPreferences implementation of LocalStorageService
class SharedPreferencesService implements LocalStorageService {
  final SharedPreferences _prefs;

  SharedPreferencesService(this._prefs);

  @override
  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    return _prefs.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<bool> setInt(String key, int value) async {
    return _prefs.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  @override
  Future<bool> clear() async {
    return _prefs.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<Set<String>> getKeys() async {
    return _prefs.getKeys();
  }
}
