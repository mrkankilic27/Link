import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  // Android emülatör için localhost karşılığı 10.0.2.2'dir
  static const String sunucuUrl = "http://10.0.2.2/link_api/add_link.php";

  static Future<bool> sunucuyaGonder({
    required File kiyafet,
    required File fis,
    required String not,
    required String baslik, // Başlığı zorunlu alıyoruz
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(sunucuUrl));

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
}
