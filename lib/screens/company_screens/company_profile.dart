import 'package:flutter/material.dart';
import 'package:staj_bul_demo/screens/company_screens/company_settings.dart';

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({super.key});

  @override
  State<CompanyProfile> createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile> {
  void navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanySettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            onPressed: navigateToSettings,
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
