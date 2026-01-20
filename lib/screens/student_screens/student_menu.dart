import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:staj_bul_demo/screens/student_screens/student_home.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/student_profile.dart';

class StudentMenuPage extends StatefulWidget {
  const StudentMenuPage({super.key});

  @override
  State<StudentMenuPage> createState() => _StudentMenuPageState();
}

class _StudentMenuPageState extends State<StudentMenuPage> {
  int _currentPage = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      StudentHomePage(
        onGoToProfile: () {
          setState(() {
            _currentPage = 3;
          });
        },
      ),
      const Text('Saved'),
      const Text('Applications'),
      const StudentProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentPage,
        children: _pages,
      ),
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
