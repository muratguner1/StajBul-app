import 'package:flutter/material.dart';
import 'package:staj_bul_demo/services/auth.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final Auth _auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Row(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(color: Colors.blue),
          ),
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
