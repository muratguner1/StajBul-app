import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/custom_text_field.dart';
import 'package:staj_bul_demo/models/company_profile_model.dart';
import 'package:staj_bul_demo/repositories/company/common_repository.dart';
import 'package:staj_bul_demo/repositories/company/company_profile_repository.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/awesome_snack_bar.dart';

class EditCompanyProfilePage extends StatefulWidget {
  final CompanyProfileModel? profileModel;
  const EditCompanyProfilePage({super.key, required this.profileModel});

  @override
  State<EditCompanyProfilePage> createState() => _EditCompanyProfilePageState();
}

class _EditCompanyProfilePageState extends State<EditCompanyProfilePage> {
  bool isLoading = false;

  final CommonRepository _commonRepository = CommonRepository();
  final CompanyProfileRepository _profileRepository =
      CompanyProfileRepository();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _populateForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _aboutController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _populateForm() {
    if (widget.profileModel != null) {
      _nameController.text = widget.profileModel!.companyName;
      _industryController.text = widget.profileModel!.industry ?? '';
      _aboutController.text = widget.profileModel!.aboutCompany ?? '';
      _websiteController.text = widget.profileModel!.website ?? '';
      _locationController.text = widget.profileModel!.location ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      AwesomeSnackBar.show(context,
          title: 'Eksik Bilgi',
          message: 'Şirket adı boş bırakılamaz.',
          contentType: ContentType.warning);
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = _commonRepository.getCurrentUser();
      if (user == null) throw Exception('Aktif kullanıcı bulunamadı!');

      CompanyProfileModel updatedModel;

      if (widget.profileModel != null) {
        updatedModel = widget.profileModel!.copyWith(
          companyName: _nameController.text.trim(),
          industry: _industryController.text.trim(),
          aboutCompany: _aboutController.text.trim(),
          website: _websiteController.text.trim(),
          location: _locationController.text.trim(),
        );
      } else {
        updatedModel = CompanyProfileModel(
          uid: user.uid,
          companyName: _nameController.text.trim(),
          industry: _industryController.text.trim(),
          aboutCompany: _aboutController.text.trim(),
          website: _websiteController.text.trim(),
          location: _locationController.text.trim(),
        );
      }

      await _profileRepository.updateCompanyProfile(updatedModel);

      if (mounted) {
        AwesomeSnackBar.show(context,
            title: 'Başarılı',
            message: 'Profiliniz başarıyla güncellendi.',
            contentType: ContentType.success);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        AwesomeSnackBar.show(context,
            title: 'Hata',
            message: 'Kaydedilirken bir sorun oluştu.',
            contentType: ContentType.failure);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Şirket Bilgileri",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _nameController,
                      icon: Icons.business,
                      labelText: 'Şirket Adı'),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _industryController,
                      icon: Icons.category,
                      labelText: 'Sektör (Örn: Bilişim, Finans)'),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _websiteController,
                      icon: Icons.language,
                      labelText: 'Web Sitesi'),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _locationController,
                      icon: Icons.location_on,
                      labelText: 'Konum / Adres'),
                  const SizedBox(height: 24),
                  const Text(
                    "Hakkımızda",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _aboutController,
                      icon: Icons.edit_note,
                      labelText:
                          'Şirketinizin vizyonundan, kültüründen ve projelerinden bahsedin...',
                      maxLines: 5),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text("Değişiklikleri Kaydet",
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
