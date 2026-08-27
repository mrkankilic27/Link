import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class SyncQueueService {
  static const _key = 'pending_sync_queue';
  static bool _processing = false;

  static Future<void> enqueue({
    required File clothes,
    required File receipt,
    required String title,
    required String note,
    required Map<String, dynamic> receiptData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = _read(prefs);
    queue.add({
      'clothes': clothes.path,
      'receipt': receipt.path,
      'title': title,
      'note': note,
      'receiptData': receiptData,
    });
    await prefs.setString(_key, jsonEncode(queue));
  }

  static Future<int> process() async {
    if (_processing) return 0;
    _processing = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      final queue = _read(prefs);
      final remaining = <Map<String, dynamic>>[];
      var synced = 0;
      for (final item in queue) {
        final clothes = File('${item['clothes']}');
        final receipt = File('${item['receipt']}');
        if (!await clothes.exists() || !await receipt.exists()) {
          remaining.add(item);
          continue;
        }
        final success = await ApiService.sunucuyaGonder(
          kiyafet: clothes,
          fis: receipt,
          not: '${item['note'] ?? ''}',
          baslik: '${item['title'] ?? 'İsimsiz Eşleşme'}',
          receiptData: item['receiptData'] is Map
              ? Map<String, dynamic>.from(item['receiptData'])
              : const {},
        );
        if (success) {
          synced++;
        } else {
          remaining.add(item);
        }
      }
      await prefs.setString(_key, jsonEncode(remaining));
      return synced;
    } finally {
      _processing = false;
    }
  }

  static List<Map<String, dynamic>> _read(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }
}
