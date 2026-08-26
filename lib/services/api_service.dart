import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  // Sunucu adresini buraya yazacaksın
  static const String sunucuUrl = "https://ornek-sunucu-adresin.com/api/upload";

  static Future<bool> sunucuyaGonder({
    required File kiyafet,
    required File fis,
    required String not,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(sunucuUrl));

      // Sıkıştırılmış KB boyutundaki dosyaları ekliyoruz
      request.files.add(
        await http.MultipartFile.fromPath('kiyafet', kiyafet.path),
      );
      request.files.add(await http.MultipartFile.fromPath('fis', fis.path));
      request.fields['not'] = not;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // İnternet yoksa veya sunucu kapalıysa yerel akışı bozmamak için false döner
      return false;
    }
  }
}
