import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/custom_info_row.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/custom_text_field.dart';
import 'package:staj_bul_demo/models/user_model.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/repositories/student/profile_repository.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/awesome_snack_bar.dart';

class ContactTab extends StatefulWidget {
  const ContactTab({super.key});

  @override
  State<ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<ContactTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final CommonRepository _commonRepository = CommonRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  UserModel? _userModel;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();

  bool isLoading = true;
  bool isEditing = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  void _populateControllers(UserModel model) {
    _emailController.text = model.email;
    _phoneController.text = model.phone ?? '';
    _addressController.text = model.address ?? '';
    _linkedinController.text = model.linkedin ?? '';
    _githubController.text = model.github ?? '';
    _portfolioController.text = model.portfolio ?? '';
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _commonRepository.getCurrentUser();
      if (user != null) {
        final model = await _commonRepository.getUserModel(user.uid);
        if (mounted) {
          setState(() {
            if (model != null) {
              _userModel = model;
              _populateControllers(model);
            }
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        AwesomeSnackBar.show(context,
            title: 'Hata',
            message: 'İletişim bilgileri alınırken hata oluştu!',
            contentType: ContentType.failure);
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userModel == null) return;

    setState(() => isLoading = true);

    try {
      await _profileRepository.updateContactInfo(
        uid: _userModel!.uid,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        linkedin: _linkedinController.text.trim(),
        github: _githubController.text.trim(),
        portfolio: _portfolioController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _userModel = UserModel(
            uid: _userModel!.uid,
            email: _userModel!.email,
            role: _userModel!.role,
            createdAt: _userModel!.createdAt,
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            linkedin: _linkedinController.text.trim(),
            github: _githubController.text.trim(),
            portfolio: _portfolioController.text.trim(),
          );
          isEditing = false;
          isLoading = false;
        });

        AwesomeSnackBar.show(context,
            title: 'Başarılı',
            message: 'İletişim bilgileri başarıyla güncellendi!',
            contentType: ContentType.success);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        AwesomeSnackBar.show(context,
            title: 'Hata',
            message: 'Bilgiler kaydedilirken bir sorun oluştu!',
            contentType: ContentType.failure);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userModel == null) {
      return const Center(child: Text('Kullanıcı bilgileri yğklenemedi!'));
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: isEditing ? _buildEditMode() : _buildViewMode(),
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('İletişim Bilgileri',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => setState(() => isEditing = true),
              label: const Text('Düzenle',
                  style: TextStyle(color: Colors.blueAccent)),
              icon: const Icon(Icons.edit, size: 18, color: Colors.blueAccent),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 10),
        CustomInfoRow(
            icon: Icons.email, value: _emailController.text, label: 'Eposta'),
        CustomInfoRow(
            icon: Icons.phone, value: _phoneController.text, label: 'Telefon'),
        CustomInfoRow(
            icon: Icons.location_on,
            value: _addressController.text,
            label: 'Adres'),
        CustomInfoRow(
            icon: Icons.link,
            value: _linkedinController.text,
            label: 'LinkedIn'),
        CustomInfoRow(
            icon: Icons.code, value: _githubController.text, label: 'GitHub'),
        CustomInfoRow(
            icon: Icons.language,
            value: _portfolioController.text,
            label: 'Portfolyo'),
      ],
    );
  }

  Widget _buildEditMode() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("İletişim Düzenle",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_userModel != null) _populateControllers(_userModel!);
                    isEditing = false;
                  });
                },
                icon: const Icon(Icons.close, color: Colors.grey),
              )
            ],
          ),
          const SizedBox(height: 16),
          CustomInfoRow(
              icon: Icons.email,
              value: _emailController.text,
              label: 'E-Posta (Değiştirilemez)'),
          const SizedBox(height: 16),
          CustomTextField(
              controller: _phoneController,
              icon: Icons.phone,
              labelText: 'Telefon Numaranız'),
          const SizedBox(height: 16),
          CustomTextField(
              controller: _addressController,
              icon: Icons.location_on,
              labelText: 'Adres'),
          const SizedBox(height: 16),
          CustomTextField(
              controller: _linkedinController,
              icon: Icons.link,
              labelText: 'LinkedIn Profil Linki'),
          const SizedBox(height: 16),
          CustomTextField(
              controller: _githubController,
              icon: Icons.code,
              labelText: 'GitHub Profil Linki'),
          const SizedBox(height: 16),
          CustomTextField(
              controller: _portfolioController,
              icon: Icons.language,
              labelText: 'Web Sitesi / Portfolyo'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      if (_userModel != null) _populateControllers(_userModel!);
                      isEditing = false;
                    });
                  },
                  child: const Text("İptal"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: ElevatedButton(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Kaydet"),
              )),
            ],
          )
        ],
      ),
    );
  }
}
