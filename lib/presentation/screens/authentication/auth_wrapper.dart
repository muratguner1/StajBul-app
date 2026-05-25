import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staj_bul_demo/data/models/user_model.dart';
import 'package:staj_bul_demo/data/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/presentation/screens/company_screens/company_menu.dart';
import 'package:staj_bul_demo/presentation/screens/authentication/login.dart';
import 'package:staj_bul_demo/presentation/screens/student_screens/student_menu.dart';
import 'package:staj_bul_demo/core/constants/user_roles.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final CommonRepository commonRepository = CommonRepository();

    final firebaseUser = commonRepository.getCurrentUser();

    if (user == null) {
      if (firebaseUser != null) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        return LoginPage();
      }
    }

    switch (user.role) {
      //sonra admin için de ekleme yap
      case UserRoles.student:
        return StudentMenuPage();
      case UserRoles.company:
        return CompanyMenuPage();
      default:
        return LoginPage();
    }
  }
}
