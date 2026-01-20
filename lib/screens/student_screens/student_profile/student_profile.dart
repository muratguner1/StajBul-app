import 'package:flutter/material.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/repositories/student/profile/header_repository.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/contact_tab.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/experiences_tab.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/personal_info_tab.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/resume_tab.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/skills_tab.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/student_settings.dart';
import 'package:staj_bul_demo/widgets/student/profile_page/profile_header.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage>
    with SingleTickerProviderStateMixin {
  final CommonRepository _commonRepository = CommonRepository();
  final HeaderRepository _headerRepository = HeaderRepository();

  String? _profileUrl;
  String? _defaultPhotoUrl;
  String? _fullName;
  String? _university;
  bool _isLoadingHeader = true;

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
    _loadHeaderData();
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

  Future<void> _loadHeaderData() async {
    final user = _commonRepository.getCurrentUser();
    if (user == null) return;

    try {
      final profileUrl = await _headerRepository.getProfileImageUrl(user.uid);
      final defaultPhotoUrl = await _headerRepository.getDefaultPhotoUrl();

      final doc = await _commonRepository.getStudentProfile(user.uid);

      String? fullName;
      String? university;

      if (doc != null && doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        fullName = data[FirestoreStudentFields.fullName];
        university = data[FirestoreStudentFields.university];
      }

      setState(() {
        _profileUrl = profileUrl;
        _defaultPhotoUrl = defaultPhotoUrl;
        _fullName = fullName;
        _university = university;
        _isLoadingHeader = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHeader = false;
      });
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
            profileUrl: _profileUrl,
            defaultPhotoUrl: _defaultPhotoUrl,
            fullName: _fullName,
            university: _university,
            isLoading: _isLoadingHeader,
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
                SkillsTab(),
                ContactTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
