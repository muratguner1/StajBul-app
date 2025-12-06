import 'package:flutter/material.dart';
import 'package:staj_bul_demo/services/auth.dart';

class CompanySettingsPage extends StatelessWidget {
  const CompanySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Auth _auth = Auth();

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _auth.logout();
            },
            child: Text('Log out'),
          ),
        ],
      ),
    );
  }
}
