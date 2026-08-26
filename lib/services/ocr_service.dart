import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:easy_localization/easy_localization.dart';

class OcrService {
  // Verilen fiş resmini tarayıp içindeki metni çıkaran fonksiyon
  static Future<String> fisiMetneDonustur(File fisResmi) async {
    final inputImage = InputImage.fromFile(fisResmi);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      await textRecognizer.close();

      // Bulunan tüm metinleri tek bir string olarak döndürüyoruz (Dil destekli)
      return recognizedText.text.isNotEmpty
          ? recognizedText.text
          : 'textNotRead'.tr();
    } catch (e) {
      await textRecognizer.close();
      return 'textNotRead'.tr();
    }
  }
}
