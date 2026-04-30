import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staj_bul_demo/core/constants/common.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/custom_info_dialog.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/custom_section_header.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/custom_settings_tile.dart';
import 'package:staj_bul_demo/providers/theme_provider.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/screens/authentication/login.dart';
import 'package:staj_bul_demo/core/services/auth.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/awesome_snack_bar.dart';

class StudentSettingsPage extends StatefulWidget {
  const StudentSettingsPage({super.key});

  @override
  State<StudentSettingsPage> createState() => _StudentSettingsPageState();
}

class _StudentSettingsPageState extends State<StudentSettingsPage> {
  final Auth _auth = Auth();
  final CommonRepository _commonRepository = CommonRepository();
  bool get _provider => Provider.of<ThemeProvider>(context).isDarkMode;

  bool _notificationsEnabled = true;
  bool _isLoadingNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _isLoadingNotifications = false;

      if (_notificationsEnabled) {
        FirebaseMessaging.instance
            .subscribeToTopic(FirebaseMessagingTopic.notification);
      }
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final messaging = FirebaseMessaging.instance;

    try {
      if (value) {
        NotificationSettings settings = await messaging.requestPermission();
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          await messaging.subscribeToTopic(FirebaseMessagingTopic.notification);
          await prefs.setBool('notifications_enabled', true);

          setState(() {
            _notificationsEnabled = true;
          });

          AwesomeSnackBar.show(context,
              title: 'Bildirimler Açıldı',
              message: 'Yeni staj ilanlarından haberdar edileceksiniz.',
              contentType: ContentType.success);
        } else {
          AwesomeSnackBar.show(context,
              title: 'İzin Gerekli',
              message:
                  'Bildirim alabilmek için telefon ayarlarından izin vermelisiniz.',
              contentType: ContentType.warning);

          setState(() {
            _notificationsEnabled = false;
          });
        }
      } else {
        await messaging
            .unsubscribeFromTopic(FirebaseMessagingTopic.notification);
        await prefs.setBool('notifications_enabled', false);

        setState(() {
          _notificationsEnabled = false;
        });

        AwesomeSnackBar.show(context,
            title: 'Bildirimler Kapatıldı',
            message: 'Artık staj ilanı bildirimi almayacaksınız.',
            contentType: ContentType.help);
      }
    } catch (e) {
      AwesomeSnackBar.show(context,
          title: 'Hata',
          message: 'Bildirim ayarı değiştirilemedi.',
          contentType: ContentType.failure);
    }
  }

  Future<void> _handleLogout() async {
    await _auth.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: _handleLogout,
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordResetDialog() {
    final user = _commonRepository.getCurrentUser();
    if (user == null || user.email == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: Text(
            '${user.email} adresine bir şifre sıfırlama bağlantısı gönderilecek. Onaylıyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _auth.resetPassword(user.email!);
                if (mounted) {
                  AwesomeSnackBar.show(context,
                      title: 'Bağlantı Gönderildi',
                      message: 'Lütfen e-posta kutunuzu kontrol edin.',
                      contentType: ContentType.success);
                }
              } catch (e) {
                if (mounted) {
                  AwesomeSnackBar.show(context,
                      title: 'Hata',
                      message: 'E-posta gönderilemedi.',
                      contentType: ContentType.failure);
                }
              }
            },
            child: const Text('Gönder', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title:
                  const Text('Hesabı Sil', style: TextStyle(color: Colors.red)),
              content: const Text(
                'Hesabınızı kalıcı olarak silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve tüm StajBul verileriniz silinir.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Vazgeç'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    final user = _commonRepository.getCurrentUser();
                    if (user == null) return;

                    try {
                      await _auth.deleteAccount(
                          user.uid, FirestoreCollections.studentProfiles);

                      if (!mounted) return;

                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                              (route) => false);
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'requires-recent-login' && mounted) {
                        AwesomeSnackBar.show(context,
                            title: 'Güvenlik Uyarısı',
                            message:
                                'Hesabınızı silmek için lütfen çıkış yapıp tekrar giriş yapın.',
                            contentType: ContentType.warning);
                      }
                    }
                  },
                  child: const Text("Evet, Sil",
                      style: TextStyle(color: Colors.white)),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ayarlar',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.blue[500],
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomSectionHeader(title: 'Hesap'),
            CustomSettingsTile(
                icon: Icons.lock_outline,
                title: 'Şifre Değiştir',
                onTap: _showPasswordResetDialog),
            CustomSettingsTile(
                icon: Icons.delete_forever,
                title: 'Hesabı Sil',
                onTap: _showDeleteAccountDialog,
                iconColor: Colors.red),
            const SizedBox(height: 20),
            CustomSectionHeader(title: 'Uygulama'),
            _isLoadingNotifications
                ? const Center(child: CircularProgressIndicator())
                : SwitchListTile(
                    secondary: const Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.blueAccent,
                    ),
                    title: const Text('Bildirimler'),
                    subtitle: const Text('Staj ilanları ve mesaj bildirimleri'),
                    value: _notificationsEnabled,
                    activeThumbColor: Colors.blueAccent,
                    onChanged: _toggleNotifications,
                  ),
            SwitchListTile(
              secondary: Icon(
                _provider ? Icons.dark_mode : Icons.light_mode,
                color: _provider ? Colors.deepPurple : Colors.orange,
              ),
              title: const Text('Karanlık Tema'),
              value: _provider,
              activeThumbColor: Colors.deepPurple,
              onChanged: (bool value) {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme(value);
              },
            ),
            const SizedBox(height: 20),
            CustomSectionHeader(title: 'Destek & Hakkında'),
            CustomSettingsTile(
                icon: Icons.help_outline,
                title: 'Yardım Merkezi',
                onTap: () => CustomInfoDialog.show(context,
                    title: 'Yardım Merkezi',
                    content:
                        'StajBul uygulamasında staj aramak veya profilinizi düzenlemekle ilgili sorun yaşıyorsanız stajbul@destek.com adresine e-posta gönderebilirsiniz.')),
            CustomSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Gizlilik Politikası',
                onTap: () => CustomInfoDialog.show(context,
                    title: 'Gizlilik Politikası',
                    content:
                        'Bilgileriniz güvenle saklanmaktadır. Üçüncü şahıslarla KVKK kapsamında belirtilen durumlar dışında kesinlikle paylaşılmaz')),
            CustomSettingsTile(
                icon: Icons.info_outline,
                title: 'Uygulama Sürümü',
                trailing: const Text('v1.0.0',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                onTap: null),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _showLogoutDialog,
                label: const Text(
                  'Çıkış Yap',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                icon: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
