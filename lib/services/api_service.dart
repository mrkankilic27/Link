import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  static String get _baseUrl =>
      kIsWeb ? 'http://localhost/link_api' : 'http://10.0.2.2/link_api';

  static String get eklemeUrl => '$_baseUrl/add_link.php';
  static String get listelemeUrl => '$_baseUrl/get_links.php';
  static String get silmeUrl => '$_baseUrl/delete.php';

  static String gorselUrl(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return path;
    }
    return '$_baseUrl/${path.replaceFirst(RegExp(r'^/+'), '')}';
  }

  static Future<Map<String, String>> _authHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }

  // 1. Yeni eşleşmeyi sunucuya (MySQL'e) gönderen metot
  static Future<bool> sunucuyaGonder({
    required Object kiyafet,
    required Object fis,
    required String not,
    required String baslik,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(eklemeUrl));
      request.headers.addAll(await _authHeaders());

      // Dosyaları ekliyoruz
      request.files.add(await _multipartFile('kiyafet', kiyafet));
      request.files.add(await _multipartFile('fis', fis));

      // Metinsel verileri sunucuya gönderiyoruz
      request.fields['baslik'] = baslik;
      request.fields['not'] = not;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        return false;
      }
      final decoded = jsonDecode(response.body);
      return decoded is Map && decoded['status'] == 'success';
    } catch (e) {
      // Hata durumunda yerel akışı bozmamak için false döner
      return false;
    }
  }

  static Future<http.MultipartFile> _multipartFile(
    String field,
    Object image,
  ) async {
    if (image is File) {
      return http.MultipartFile.fromPath(field, image.path);
    }
    if (image is XFile) {
      return http.MultipartFile.fromBytes(
        field,
        await image.readAsBytes(),
        filename: image.name,
      );
    }
    throw ArgumentError('Desteklenmeyen görsel türü.');
  }

  // 2. Sunucudaki tüm kayıtları çeken metot
  static Future<List<dynamic>> sunucudanVerileriGetir() async {
    try {
      final response = await http.get(
        Uri.parse(listelemeUrl),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success') {
          return decoded['data'];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 3. Sunucudan ID'ye göre kayıt silen metot
  static Future<bool> sunucudanKayitSil(int id) async {
    try {
      final response = await http.post(
        Uri.parse(silmeUrl),
        headers: await _authHeaders(),
        body: {'id': id.toString()},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['status'] == 'success';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
