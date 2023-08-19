import 'package:cache_data_app/cache/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedCacheData {
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  Future<bool> setCacheData(String data, Duration expirationDuration) async {
    try {
      final _prefs = await prefs;
      DateTime expiration = DateTime.now().add(expirationDuration);

      await _prefs.setString(cacheDataKey, data);
      await _prefs.setString(
          cacheDataExpirationKey, expiration.toIso8601String());

      return true;
    } catch (e) {
      print('Error saving data in storage ${e.toString()}');
      return false;
    }
  }

  Future<String?> getCacheData(String key) async {
    try {
      final _prefs = await prefs;
      String? data = _prefs.getString(key);
      String? expiration = _prefs.getString('expiration_$key');
      if (data != null && expiration != null) {
        DateTime expirationTime = DateTime.parse(expiration);
        if (expirationTime.isAfter(DateTime.now())) {
          // data has not expired
          return data;
        } else {
          await clearCache(key);
          return null;
        }
      }
      return null;
    } catch (e) {
      // Todo handle error
      return null;
    }
  }

  Future<void> clearCache(String cacheKey) async {
    try {
      final _prefs = await prefs;
      await _prefs.remove(cacheKey);
      await _prefs.remove('expiration_$cacheKey');
      print('Data cleared from Cache');
    } catch (e) {
      print('Cannot clear data cache right now.');
    }
  }
}
