import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageService {
  static Future<File> fotografSikistir(File orijinalDosya) async {
    final dizin = await getTemporaryDirectory();
    final hedefYol = p.join(
      dizin.path,
      '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
    );

    // Fotoğrafı kalitesini %70'e düşürerek ve boyutunu küçülterek KB seviyesine sıkıştırıyoruz
    var compressedFile = await FlutterImageCompress.compressAndGetFile(
      orijinalDosya.absolute.path,
      hedefYol,
      quality: 70, // Kalite oranı (sunucu için ideal)
      minWidth: 1000, // Maksimum genişlik sınırı
      minHeight: 1000, // Maksimum yükseklik sınırı
    );

    return File(compressedFile!.path);
  }
}
