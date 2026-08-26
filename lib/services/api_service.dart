import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  // Android emülatör için localhost karşılığı 10.0.2.2'dir
  static const String eklemeUrl = "http://10.0.2.2/link_api/add_link.php";
  static const String listelemeUrl = "http://10.0.2.2/link_api/get_links.php";
  static const String silmeUrl = "http://10.0.2.2/link_api/delete.php";

  // 1. Yeni eşleşmeyi sunucuya (MySQL'e) gönderen metot
  static Future<bool> sunucuyaGonder({
    required File kiyafet,
    required File fis,
    required String not,
    required String baslik,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(eklemeUrl));

      // Dosyaları ekliyoruz
      request.files.add(
        await http.MultipartFile.fromPath('kiyafet', kiyafet.path),
      );
      request.files.add(await http.MultipartFile.fromPath('fis', fis.path));

      // Metinsel verileri sunucuya gönderiyoruz
      request.fields['baslik'] = baslik;
      request.fields['not'] = not;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // Hata durumunda yerel akışı bozmamak için false döner
      return false;
    }
  }

  // 2. Sunucudaki tüm kayıtları çeken metot
  static Future<List<dynamic>> sunucudanVerileriGetir() async {
    try {
      final response = await http.get(Uri.parse(listelemeUrl));

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
