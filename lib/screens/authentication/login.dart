import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/widgets/custom_widgets/awesome_snack_bar.dart';
import 'package:staj_bul_demo/screens/authentication/reset_password.dart';
import 'package:staj_bul_demo/screens/authentication/register.dart';
import 'package:staj_bul_demo/screens/company_screens/company_menu.dart';
import 'package:staj_bul_demo/screens/student_screens/student_menu.dart';
import 'package:staj_bul_demo/services/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loaded = true;
  final Auth _auth = Auth();
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenH * 0.15),
            Text(
              'Staj Bul',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(
              height: screenH * 0.08,
            ),
            Center(
              child: Container(
                width: screenW * 0.85,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Tekrar Hoş Geldin',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        enabled: loaded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Litfen e-posta gir!';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'E-Posta',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        enabled: loaded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Litfen şifre gir!';
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final emailInput = _emailController.text.trim();
                              final passwordInput =
                                  _passwordController.text.trim();

                              setState(() {
                                loaded = false;
                              });
                              try {
                                final user = await _auth.login(
                                  emailInput,
                                  passwordInput,
                                );

                                if (user != null) {
                                  _emailController.clear();
                                  _passwordController.clear();
                                  if (user.role == 'student') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StudentMenuPage(),
                                      ),
                                    );
                                  } else if (user.role == 'company') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CompanyMenuPage(),
                                      ),
                                    );
                                  } else {
                                    AwesomeSnackBar.show(context,
                                        title: 'Başarısız!',
                                        message: 'Geçersiz kullanıcı!',
                                        contentType: ContentType.failure);
                                  }
                                } else {
                                  AwesomeSnackBar.show(context,
                                      title: 'Başarısız!',
                                      message: 'E-posta veya şifre hatalı!',
                                      contentType: ContentType.failure);
                                }
                              } catch (e) {
                                AwesomeSnackBar.show(context,
                                    title: 'Başarısız!',
                                    message:
                                        'Giriş başarısız, lütfen şifre ve e-postayı doğru yazdığından emin ol!',
                                    contentType: ContentType.failure);
                              }

                              setState(() {
                                loaded = true;
                              });
                            } else {
                              print("Form geçersiz");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: loaded
                              ? Text(
                                  'Giriş Yap',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                )
                              : CircularProgressIndicator(),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResetPasswordPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Şifremi unuttum',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hesabın yok mu?',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Kayıt ol",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
