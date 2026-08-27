import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    if (kIsWeb) return true;
    try {
      if (!await _auth.isDeviceSupported()) return true;
      return await _auth.authenticate(
        localizedReason: 'Link uygulamasını açmak için doğrulama yapın',
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
