import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:staj_bul_demo/screens/company_screens/home/company_home.dart';
import 'package:staj_bul_demo/screens/company_screens/posts/company_posts_page.dart';
import 'package:staj_bul_demo/screens/company_screens/profile/company_profile.dart';

class CompanyMenuPage extends StatefulWidget {
  const CompanyMenuPage({super.key});

  @override
  State<CompanyMenuPage> createState() => _CompanyMenuPageState();
}

class _CompanyMenuPageState extends State<CompanyMenuPage> {
  int _currentPage = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      CompanyHomePage(),
      CompanyPostsPage(),
      Text('Mesalar'),
      CompanyProfilePage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'İlanlar'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Mesajlar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
