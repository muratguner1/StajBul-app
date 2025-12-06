import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:staj_bul_demo/screens/student_screens/student_home.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile.dart';

class StudentMenuPage extends StatefulWidget {
  const StudentMenuPage({super.key});

  @override
  State<StudentMenuPage> createState() => _StudentMenuPageState();
}

class _StudentMenuPageState extends State<StudentMenuPage> {
  int _currentPage = 0;

  final List<Widget> _pages = [
    StudentHomePage(),
    Text('Saved'),
    Text('Applications'),
    StudentProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        currentIndex: _currentPage,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.home), label: 'Ana sayfa'),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.bookmark), label: 'Kaydedilenler'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assessment), label: 'Başvurularım'),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.user), label: 'Profil'),
        ],
      ),
    );
  }
}
