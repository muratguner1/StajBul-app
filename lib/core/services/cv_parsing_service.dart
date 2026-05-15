import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';

class CVParsingService {
  static Future<String> extractTextFromPDF(File file) async {
    try {
      LogService.info('PDF metni ayıklanıyor (Arka planda)...');

      final List<int> bytes = await file.readAsBytes();

      final String text = await compute(_parsePdfBytes, bytes);

      if (text.isEmpty) {
        LogService.info(
            'PDF okundu ama içinden metin çıkmadı (Fotoğraf veya bozuk olabilir).');
      } else {
        LogService.info(
            'PDF ayıklama başarılı. Karakter sayısı: ${text.length}');
      }

      return text;
    } catch (e) {
      LogService.error(
          'PDF okunurken uygulamanın çökmesi engellendi!', e, null);
      return "";
    }
  }

  static String _parsePdfBytes(List<int> bytes) {
    try {
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      String text = PdfTextExtractor(document).extractText();
      document.dispose();

      if (text.length > 4000) {
        return text.substring(0, 4000);
      }
      return text.trim();
    } catch (e) {
      return "";
    }
  }
}
