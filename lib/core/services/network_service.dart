import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkService {
  static Future<bool> hasInternetConnection() async {
    if (kIsWeb) {
      return true; // Fallback to true on web platform
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}
    return false;
  }
}
