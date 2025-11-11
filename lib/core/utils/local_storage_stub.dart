import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToLocalStorage(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<String?> getFromLocalStorage(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<void> removeFromLocalStorage(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}
