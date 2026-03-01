import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staj_bul_demo/providers/theme_provider.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/screens/authentication/login.dart';
import 'package:staj_bul_demo/services/auth.dart';
import 'package:staj_bul_demo/widgets/custom_widgets/awesome_snack_bar.dart';

class StudentSettingsPage extends StatefulWidget {
  const StudentSettingsPage({super.key});

  @override
  State<StudentSettingsPage> createState() => _StudentSettingsPageState();
}

//TODO: uygulama açıldığında login sayfasına gidiyor
//TODO: bildirimleri hallet

class _StudentSettingsPageState extends State<StudentSettingsPage> {
  final Auth _auth = Auth();
  final CommonRepository _commonRepository = CommonRepository();
  bool get _provider => Provider.of<ThemeProvider>(context).isDarkMode;

  bool _notificationsEnabled = true;
  bool _isDarkMode = false;

  Future<void> _handleLogout() async {
    await _auth.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  void _showPasswordResetDialog() {
    final user = _commonRepository.getCurrentUser();
    if (user == null || user.email == null) return;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Şifre Değiştir'),
              content: Text(
                  '${user.email} adresine bir şifre sıfırlama bağlantısı gönderilecek. Onaylıyor musunuz?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      const Text('İptal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                  onPressed: () async {
                    Navigator.pop(context);
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
                  child: const Text('Gönder',
                      style: TextStyle(color: Colors.white)),
                )
              ],
            ));
  }

  void _showDeleteAccountDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title:
                  const Text('Hesabı Sil', style: TextStyle(color: Colors.red)),
              content: const Text(
                'Hesabınızı kalıcı olarak silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve tüm StajBul verileriniz silinir.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Vazgeç'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      final user = _commonRepository.getCurrentUser();
                      await _auth.deleteAccount(user!.uid);
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                            (Route<dynamic> route) => false);
                      }
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

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kapat"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ayarlar',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Hesap'),
            _buildSettingsTile(
                icon: Icons.lock_outline,
                title: 'Şifre Değiştir',
                onTap: _showPasswordResetDialog),
            _buildSettingsTile(
                icon: Icons.delete_forever,
                title: 'Hesabı Sil',
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: _showDeleteAccountDialog),
            const SizedBox(height: 20),
            _buildSectionHeader('Uygulama'),
            SwitchListTile(
              secondary: const Icon(
                Icons.notifications_active_outlined,
                color: Colors.blueAccent,
              ),
              title: const Text('Bildirimler'),
              subtitle: const Text('Staj ilanları ve mesaj bildirimleri'),
              value: _notificationsEnabled,
              activeThumbColor: Colors.blueAccent,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
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
            _buildSectionHeader('Destek & Hakkında'),
            _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Yardım Merkezi',
                onTap: () => _showInfoDialog('Yardım Merkezi',
                    'StajBul uygulamasında staj aramak veya profilinizi düzenlemekle ilgili sorun yaşıyorsanız stajbul@destek.com adresine e-posta gönderebilirsiniz.')),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Gizlilik Politikası',
              onTap: () => _showInfoDialog('Gizlilik Politikası',
                  'Bilgileriniz güvenle saklanmaktadır. Üçüncü şahıslarla KVKK kapsamında belirtilen durumlar dışında kesinlikle paylaşılmaz'),
            ),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'Uygulama Sürümü',
              trailing: const Text('v1.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              onTap: null,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
      {required IconData icon,
      required String title,
      VoidCallback? onTap,
      Color? textColor,
      Color? iconColor,
      Widget? trailing}) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}
