import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/custom_info_row.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/custom_section_card.dart';
import 'package:staj_bul_demo/models/company_profile_model.dart';
import 'package:staj_bul_demo/repositories/company/common_repository.dart';
import 'package:staj_bul_demo/repositories/company/profile_repository.dart';
import 'package:staj_bul_demo/screens/company_screens/profile/company_settings.dart';
import 'package:staj_bul_demo/screens/company_screens/profile/edit_company_profile.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/awesome_snack_bar.dart';

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
                    EditCompanyProfilePage(profileModel: _profileModel)))
        .then((value) {
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
                    child: Icon(Icons.business, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _profileModel?.companyName ?? 'Şirket Adı Belirtilmemiş',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profileModel?.industry ?? '---',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: navigateToEditProfile,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.blueAccent,
                      ),
                      label: const Text(
                        'Profili Düzenle',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomSectionCard(
                    title: 'Hakkımızda',
                    icon: Icons.info_outline,
                    child: Text(
                      (_profileModel?.aboutCompany == null ||
                              _profileModel!.aboutCompany!.isEmpty)
                          ? 'Henüz bir açıklama eklenmemiş'
                          : _profileModel!.aboutCompany!,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomSectionCard(
                    title: 'İletşim & Konum',
                    icon: Icons.contact_mail_outlined,
                    child: Column(
                      children: [
                        CustomInfoRow(
                            icon: Icons.language,
                            value: _profileModel?.website ?? '',
                            label: 'Web Sitesi'),
                        CustomInfoRow(
                            icon: Icons.location_on,
                            value: _profileModel?.location ?? '',
                            label: 'Konum'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
