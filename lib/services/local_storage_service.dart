import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyGuestHooks = 'guest_hooks';

  // Misafir verilerini kaydetme
  static Future<void> saveGuestHooks(List<Map<String, dynamic>> hooks) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(hooks);
    await prefs.setString(_keyGuestHooks, encodedData);
  }

  // Misafir verilerini okuma
  static Future<List<Map<String, dynamic>>> getGuestHooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_keyGuestHooks);
    if (encodedData == null) return [];

    final List<dynamic> decodedList = jsonDecode(encodedData);
    return decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // Misafir verilerini temizleme (Örn: Giriş yapıldığında buluta aktarıp yereli silmek için)
  static Future<void> clearGuestHooks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGuestHooks);
  }
}
