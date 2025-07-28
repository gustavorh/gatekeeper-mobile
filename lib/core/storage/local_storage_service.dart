/// Abstract interface for local storage operations
abstract class LocalStorageService {
  /// Store a string value
  Future<bool> setString(String key, String value);

  /// Retrieve a string value
  Future<String?> getString(String key);

  /// Store a boolean value
  Future<bool> setBool(String key, bool value);

  /// Retrieve a boolean value
  Future<bool?> getBool(String key);

  /// Store an integer value
  Future<bool> setInt(String key, int value);

  /// Retrieve an integer value
  Future<int?> getInt(String key);

  /// Remove a value by key
  Future<bool> remove(String key);

  /// Clear all stored values
  Future<bool> clear();

  /// Check if a key exists
  Future<bool> containsKey(String key);

  /// Get all keys
  Future<Set<String>> getKeys();
}
