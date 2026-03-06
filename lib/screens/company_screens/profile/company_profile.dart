import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/models/company_profile_model.dart';
import 'package:staj_bul_demo/repositories/company/common_repository.dart';
import 'package:staj_bul_demo/repositories/company/profile_repository.dart';
import 'package:staj_bul_demo/screens/company_screens/company_settings.dart';
import 'package:staj_bul_demo/screens/company_screens/profile/edit_company_profile.dart';
import 'package:staj_bul_demo/widgets/custom_widgets/awesome_snack_bar.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  bool isLoading = false;

  final CommonRepository _commonRepository = CommonRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  CompanyProfileModel? _profileModel;

  @override
  void initState() {
    super.initState();
    _fetchCompanyData();
  }

  Future<void> _fetchCompanyData() async {
    try {
      final user = _commonRepository.getCurrentUser();
      if (user == null) return;

      final profile = await _profileRepository.getCompanyProfileModel(user.uid);

      if (mounted) {
        setState(() {
          _profileModel = profile;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        AwesomeSnackBar.show(context,
            title: 'Hata',
            message: 'Profil bilgileri yüklenemedi.',
            contentType: ContentType.failure);
      }
    }
  }

  // Future<void> _saveCompanyData() async {
  //   final user = _commonRepository.getCurrentUser();
  //   if (user == null) return;

  //   if (_nameController.text.trim().isEmpty) {
  //     AwesomeSnackBar.show(context,
  //         title: 'Uyarı',
  //         message: 'Şirket adı boş bırakılamaz.',
  //         contentType: ContentType.warning);
  //     return;
  //   }

  //   setState(() => isLoading = true);

  //   try {
  //     final updatedProfile = _profileModel!.copyWith(
  //       companyName: _nameController.text.trim(),
  //       industry: _industryController.text.trim(),
  //       aboutCompany: _aboutController.text.trim(),
  //       website: _websiteController.text.trim(),
  //       location: _locationController.text.trim(),
  //     );

  //     await _profileRepository.updateCompanyProfile(updatedProfile);

  //     if (mounted) {
  //       setState(() {
  //         _profileModel = updatedProfile;
  //         isEditing = false;
  //         isLoading = false;
  //       });

  //       AwesomeSnackBar.show(context,
  //           title: 'Başarılı',
  //           message: 'Şirket profiliniz güncellendi.',
  //           contentType: ContentType.success);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() => isLoading = false);
  //       AwesomeSnackBar.show(context,
  //           title: 'Hata',
  //           message: 'Kaydedilirken bir sorun oluştu.',
  //           contentType: ContentType.failure);
  //     }
  //   }
  // }

  void navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanySettingsPage(),
      ),
    );
  }

  void navigateToEditProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditCompanyProfile(profileModel: _profileModel))).then((value) {
      if (value == true) {
        _fetchCompanyData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: navigateToSettings,
              icon: Icon(Icons.settings),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent,
                      child:
                          Icon(Icons.business, size: 50, color: Colors.white),
                    )
                  ],
                ),
              ));
  }
}
