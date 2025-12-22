import 'package:flutter/material.dart';
import 'package:staj_bul_demo/repositories/student_profile_repository.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/experiences_tab.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/personal_info_tab.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/resume_tab.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/student_settings.dart';
import 'package:staj_bul_demo/widgets/student/profile_page/profile_header.dart';
import 'package:staj_bul_demo/widgets/student/profile_page/tab_content.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage>
    with SingleTickerProviderStateMixin {
  final StudentProfileRepository _repository = StudentProfileRepository();
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
    final user = _repository.getCurrentUser();
    if (user == null) return;

    try {
      final url = await _repository.getProfileImageUrl(user.uid);
      setState(() {
        _profileUrl = url;
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              children: [
                const PersonalInfoTab(),
                ExperiencesTab(),
                ResumeTab(),
                TabContent(title: 'Yetenekler & Diller'),
                TabContent(
                    title:
                        'İletişim Bilgileri'), // bu özel widget sonra silinecek.
              ],
            ),
          ),
        ],
      ),
    );
  }
}
