import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/screens/student_screens/student_settings.dart';
import 'package:staj_bul_demo/widgets/student/profile_header.dart';
import 'package:staj_bul_demo/widgets/student/tab_content.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _profileUrl;

  late TabController _tabController;
  final List<Tab> _tabList = [
    Tab(text: 'Kişisel Bilgiler'),
    Tab(text: 'Deneyimler'),
    Tab(text: 'Özgeçmiş'),
    Tab(text: 'Yetenekler & Diller'),
    Tab(text: 'İletişim Bilgileri'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabList.length, vsync: this);
    _setProfileUrl();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentSettingsPage(),
      ),
    );
  }

  Future<void> _setProfileUrl() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      DocumentSnapshot doc =
          await _firestore.collection('studentProfiles').doc(user.uid).get();

      setState(() {
        _profileUrl = doc['profileImageUrl'];
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          IconButton(
            onPressed: _navigateToSettings,
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          ProfileHeader(
            currentProfileUrl: _profileUrl,
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: _tabList,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children:
                  _tabList.map((tab) => TabContent(title: tab.text!)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
