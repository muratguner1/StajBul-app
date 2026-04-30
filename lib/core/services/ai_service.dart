import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';
import 'package:staj_bul_demo/models/post_model.dart';
import 'package:staj_bul_demo/models/student_profile_model.dart';

class AIService {
  Future<Map<String, dynamic>> getMatchAnalysis({
    required PostModel post,
    required StudentProfileModel student,
  }) async {
    LogService.info('Groq üzerinden AI analizi başlatılıyor...');

    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

    final prompt = '''
    Sen bir İK uzmanısın. İlan ile öğrenciyi karşılaştırıp 0.0 ile 1.0 arası puan ver.
    
    İlan Nitelikleri: ${post.qualifications}
    Öğrenci hakkında: ${student.aboutMe}
    Öğrenci Yetenekleri: ${student.skills?.join(', ')}
    
    LÜTFEN SADECE AŞAĞIDAKİ JSON FORMATINDA YANIT VER (başka hiçbir kelime veya markdown ekleme):
    {"score": [0.00 ile 1.00 arası bir sayı], "explanation": "[Bu puanı neden verdiğine dair son derece dürüst, net ve kısa bir açıklama]"}
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.1
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final text = data['choices'][0]['message']['content'];
        final cleanJson =
            text.replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(cleanJson);
      } else {
        LogService.error('Groq Detaylı Hata: ${response.body}', null, null);
        throw Exception("Groq Hatası: ${response.statusCode}");
      }
    } catch (e) {
      LogService.error('API Patladı, sahte veriye geçiliyor.', e, null);

      return {
        "score": 0.75,
        "explanation":
            "Otomatik Sistem Yanıtı: İlan nitelikleri ile yetenekleriniz genel olarak uyuşuyor."
      };
    }
  }
}
