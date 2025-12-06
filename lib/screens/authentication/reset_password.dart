import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/services/auth.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final Auth _auth = Auth();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loaded = true;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.grey[300]),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenH / 10),
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
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_outlined,
                              color: Colors.amber,
                              size: 35,
                            ),
                            SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                'E-posta adresinize bir şifre sıfırlama bağlantısı gönderilicektir.\nLütfen posta kutunuzu kontrol ediniz!',
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
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
                        SizedBox(height: 80),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loaded
                                ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        loaded = true;
                                      });
                                      try {
                                        await _auth.resedPassword(
                                            _emailController.text.trim());
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            elevation: 0,
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.transparent,
                                            content: AwesomeSnackbarContent(
                                              title: 'Başarılı',
                                              message:
                                                  'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.',
                                              contentType: ContentType.warning,
                                              color: Colors.amberAccent,
                                              inMaterialBanner: false,
                                            ),
                                          ),
                                        );
                                        Navigator.pop(context);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            elevation: 0,
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.transparent,
                                            content: AwesomeSnackbarContent(
                                              title: 'Başarısız',
                                              message:
                                                  'Bağlantı gönderme başarısız, e-postanızı doğru girdiğinizden emin olun!',
                                              contentType: ContentType.failure,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: loaded
                                ? Text(
                                    'Bağlantı gönder',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  )
                                : CircularProgressIndicator(),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Geri dön',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
