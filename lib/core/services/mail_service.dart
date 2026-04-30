import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';

class MailService {
  final String _username = dotenv.env['GMAIL'] ?? '';
  final String _password = dotenv.env['APP_PASSWORD'] ?? '';

  Future<void> sendStatusMail({
    required String toEmail,
    required String studentName,
    required String companyName,
    required String status,
  }) async {
    if (_username.isEmpty || _password.isEmpty) {
      LogService.error('Mail bilgileri .env dosyasında eksik!', null, null);
      return;
    }

    final smtpServer = gmail(_username, _password);

    String subject = '';
    String htmlBody = '';

    if (status == 'Kabul Edildi') {
      subject = 'Staj Başvurunuz Hakkında Bilgilendirme';
      htmlBody = '''
        <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #333; max-width: 600px; margin: auto; border: 1px solid #e0e0e0; border-radius: 8px; padding: 20px;">
          <h2 style="color: #2E7D32; text-align: center;">Tebrikler $studentName! 🎉</h2>
          <p style="font-size: 16px; line-height: 1.5;">Büyük bir mutlulukla bildirmek isteriz ki, <strong>$companyName</strong> firmasına yaptığınız staj başvurusu <strong>Kabul Edildi</strong>.</p>
          <p style="font-size: 16px; line-height: 1.5;">Önümüzdeki günlerde şirket yetkilileri sizinle iletişim bilgileriniz üzerinden irtibata geçecektir. Yeteneklerinizi sahada göstermeniz için harika bir fırsat!</p>
          <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
          <p style="font-size: 14px; color: #777; text-align: center;">Başarılar dileriz,<br><strong>StajBul Ekibi</strong></p>
        </div>
      ''';
    } else if (status == 'Reddedildi') {
      subject = 'Staj Başvurunuz Hakkında Bilgilendirme';
      htmlBody = '''
        <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #333; max-width: 600px; margin: auto; border: 1px solid #e0e0e0; border-radius: 8px; padding: 20px;">
          <h2 style=" text-align: center;">Merhaba $studentName,</h2>
          <p style="font-size: 16px; line-height: 1.5;"><strong>$companyName</strong> firmasına yaptığınız staj başvurunuz dikkatle incelenmiş olup, ne yazık ki bu dönem için <strong>olumsuz</strong> sonuçlanmıştır.</p>
          <p style="font-size: 16px; line-height: 1.5;">Bu durum yeteneklerinizin eksikliğinden değil, firmanın mevcut kadro ihtiyaçlarından kaynaklanmaktadır. Lütfen pes etmeyin, sistemimizde sizi bekleyen onlarca farklı ilan var!</p>
          <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
          <p style="font-size: 14px; color: #777; text-align: center;">Kariyer yolculuğunuzda başarılar dileriz,<br><strong>StajBul Ekibi</strong></p>
        </div>
      ''';
    } else {
      return;
    }

    final message = Message()
      ..from = Address(_username, 'StajBul İK Ekibi')
      ..recipients.add(toEmail)
      ..subject = subject
      ..html = htmlBody;

    try {
      LogService.info('Mail gönderimi başlatıldı: $toEmail');
      await send(message, smtpServer);
      LogService.info('Mail başarıyla iletildi: $status');
    } catch (e, stackTrace) {
      LogService.error('Mail gönderilemedi', e, stackTrace);
    }
  }
}
