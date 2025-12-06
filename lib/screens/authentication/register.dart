import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/widgets/custom_widgets/awesome_snack_bar.dart';
import 'package:staj_bul_demo/screens/authentication/login.dart';
import 'package:staj_bul_demo/services/auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final Auth _auth = Auth();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool loaded = true;

  int _selectedRoleIndex = 0;
  final List<String> _roles = ['student', 'company'];
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[300],
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenH * 0.15),
              SizedBox(height: screenH * 0.05),
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
                          'Kayıt ol',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ToggleButtons(
                          isSelected: [
                            _selectedRoleIndex == 0,
                            _selectedRoleIndex == 1,
                          ],
                          onPressed: (index) {
                            setState(() {
                              _selectedRoleIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          selectedColor: Colors.white,
                          fillColor: Colors.blueAccent,
                          color: Colors.blueAccent,
                          constraints: BoxConstraints(
                            minWidth: screenW / 3,
                            minHeight: screenH / 20,
                          ),
                          children: [
                            Text(
                              'Öğrenci',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Şirket',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          enabled: loaded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen isim gir!';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: _selectedRoleIndex == 0
                                ? 'Ad ve soy ad'
                                : 'Şirket ismi',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          enabled: loaded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen e-posta gir!';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'E-posta',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          obscureText: true,
                          controller: _passwordController,
                          enabled: loaded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen şifre gir!';
                            }
                            return null;
                          },
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
                            onPressed: loaded
                                ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        loaded = false;
                                      });
                                      try {
                                        final user = await _auth.register(
                                            _emailController.text.trim(),
                                            _passwordController.text.trim(),
                                            _roles[_selectedRoleIndex],
                                            _nameController.text.trim());
                                        if (user != null) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LoginPage(),
                                            ),
                                          );
                                          AwesomeSnackBar.show(context,
                                              title: 'Kayıt Başarılı',
                                              message:
                                                  'Kayıt başarılı, lütfen giriş yapın.',
                                              contentType: ContentType.success);
                                        } else {
                                          AwesomeSnackBar.show(context,
                                              title: 'Kayıt Başarısız!',
                                              message:
                                                  'Girdiğiniz e-posta başka bir kullanıcı tarafından kullanılıyor!',
                                              contentType: ContentType.failure);
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Hata oluştu: $e'),
                                          ),
                                        );
                                      } finally {
                                        setState(() {
                                          loaded = true;
                                        });
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
                                    'Kayıt ol',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  )
                                : CircularProgressIndicator(),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Zaten bir hesabın var mı?',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Giriş yap',
                                style: TextStyle(color: Colors.blueAccent),
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
      ),
    );
  }
}
