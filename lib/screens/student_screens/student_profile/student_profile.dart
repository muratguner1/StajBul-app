import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/repositories/student/profile/profile_repository.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/contact_tab.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/experiences_tab.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/personal_info_tab.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/resume_tab.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/skills_tab.dart';
import 'package:staj_bul_demo/screens/student_screens/student_profile/student_settings.dart';
import 'package:staj_bul_demo/widgets/custom_widgets/awesome_snack_bar.dart';
import 'package:staj_bul_demo/widgets/student/profile_page/profile_header.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage>
    with SingleTickerProviderStateMixin {
  final CommonRepository _commonRepository = CommonRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

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
      final profileUrl = await _profileRepository.getProfileImageUrl(user.uid);
      final defaultPhotoUrl = await _profileRepository.getDefaultPhotoUrl();

      final model = await _commonRepository.getStudentProfileModel(user.uid);

      String? fullName;
      String? university;

      if (model != null) {
        fullName = model.fullName;
        university = model.university;
      }

      if (!mounted) return;

      setState(() {
        _profileUrl = profileUrl;
        _defaultPhotoUrl = defaultPhotoUrl;
        _fullName = fullName;
        _university = university;
        _isLoadingHeader = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingHeader = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    Navigator.pop(context);

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final user = _commonRepository.getCurrentUser();
      if (user == null) return;

      if (!mounted) return;
      setState(() => _isLoadingHeader = true);

      await _profileRepository.uploadProfileImage(user.uid, File(image.path));
      await _loadHeaderData();
    } catch (e) {
      AwesomeSnackBar.show(context,
          title: '',
          message: 'Fotoğraf seçilirken bir hata oluştu!',
          contentType: ContentType.failure);
    }
  }

  Future<void> _removeImage() async {
    Navigator.pop(context);

    try {
      final user = _commonRepository.getCurrentUser();
      if (user == null) return;

      if (!mounted) return;
      setState(() => _isLoadingHeader = true);

      await _profileRepository.deleteProfileImage(user.uid);
      await _loadHeaderData();
    } catch (e) {
      AwesomeSnackBar.show(context,
          title: '',
          message: 'Fotoğraf silirken bir hata oluştu!',
          contentType: ContentType.failure);
    }
  }

  void _showFullImage() {
    ImageProvider image;
    if (_profileUrl != null && _profileUrl!.isNotEmpty) {
      image = CachedNetworkImageProvider(_profileUrl!);
    } else if (_defaultPhotoUrl != null && _defaultPhotoUrl!.isNotEmpty) {
      image = CachedNetworkImageProvider(_defaultPhotoUrl!);
    } else {
      image = const AssetImage('assets/images/default_photo.jpg');
    }
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: image,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileOptions() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blue),
                title: const Text('Profil Fotoğrafını Gör'),
                onTap: () {
                  Navigator.pop(context);
                  _showFullImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Fotoğraf Yükle/Değiştir'),
                onTap: _pickAndUploadImage,
              ),
              if (_profileUrl != null && _profileUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Profil fotoğrafını kaldır'),
                  onTap: _removeImage,
                ),
              const SizedBox(height: 10),
            ],
          ));
        });
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
            onEditTab: _showProfileOptions,
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
