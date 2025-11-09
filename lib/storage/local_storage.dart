import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  static const _key = 'saved_quote_v1';

  static Future<void> save(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json);
  }

  static Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
