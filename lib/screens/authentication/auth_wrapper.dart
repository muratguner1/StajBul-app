import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staj_bul_demo/models/user_model.dart';
import 'package:staj_bul_demo/screens/student_screens/student_home.dart';
import 'package:staj_bul_demo/screens/authentication/login.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    if (user == null) {
      return LoginPage();
    }

    switch (user.role) {
      case 'student':
        return StudentHomePage();
      case 'company':
        return StudentHomePage(); // sonra düzelt unutma
      default:
        return LoginPage();
    }
  }
}
