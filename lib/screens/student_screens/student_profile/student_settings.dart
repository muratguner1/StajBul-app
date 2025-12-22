import 'package:flutter/material.dart';
import 'package:staj_bul_demo/screens/authentication/login.dart';
import 'package:staj_bul_demo/services/auth.dart';

class StudentSettingsPage extends StatefulWidget {
  const StudentSettingsPage({super.key});

  @override
  State<StudentSettingsPage> createState() => _StudentSettingsPageState();
}

final Auth auth = Auth();

class _StudentSettingsPageState extends State<StudentSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              auth.logout();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text('Log out'),
          ),
        ],
      ),
    );
  }
}
