import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? sharedPreferences;
  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> putData({
    required String key,
    required String value,
  }) async {
    return await sharedPreferences!.setString(key, value);
  }

  static Future<bool> putLan({
    required String key,
    required bool value,
  }) async {
    return await sharedPreferences!.setBool(key, value);
  }

  /// Clear all cached data
  static Future<bool> clearCache() async {
    return await sharedPreferences!.clear();
  }

  static String? getData({
    required String key,
  }) {
    return sharedPreferences!.getString(key);
  }

  static bool? getLan({
    required String key,
  }) {
    return sharedPreferences!.getBool(key);
  }

  static Future<bool> putImageSliderData({
    required String key,
    required List<String> value,
  }) async {
    return await sharedPreferences!.setStringList(key, value);
  }

  static List<String>? getImageSliderData({
    required String key,
  }) {
    return sharedPreferences!.getStringList(key);
  }
}
