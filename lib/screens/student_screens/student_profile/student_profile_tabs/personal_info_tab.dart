import 'package:flutter/material.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/custom_info_row.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/custom_text_field.dart';
import 'package:staj_bul_demo/models/student_profile_model.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/repositories/student/student_profile_repository.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/awesome_snack_bar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class PersonalInfoTab extends StatefulWidget {
  const PersonalInfoTab({super.key});

  @override
  State<PersonalInfoTab> createState() => _PersonalInfoTabState();
}

class _PersonalInfoTabState extends State<PersonalInfoTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final CommonRepository _commonRepository = CommonRepository();
  final StudentProfileRepository _profileRepository =
      StudentProfileRepository();
  StudentProfileModel? _profileModel;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _startYearController = TextEditingController();
  final TextEditingController _graduationYearController =
      TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  bool isLoading = false;
  bool isEditing = false;

  Map<String, dynamic> backupData = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _populateControllers(StudentProfileModel model) {
    _nameController.text = model.fullName;
    _universityController.text = model.university ?? '';
    _startYearController.text = model.startYear ?? '';
    _graduationYearController.text = model.graduationYear ?? '';
    _departmentController.text = model.department ?? '';
    _classController.text = model.studentClass ?? '';
    _aboutController.text = model.aboutMe ?? '';
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _commonRepository.getCurrentUser();

      if (user != null) {
        final model = await _profileRepository.getStudentProfileModel(user.uid);
        if (mounted) {
          setState(() {
            if (model != null) {
              _profileModel = model;
              _populateControllers(model);
            } else {
              AwesomeSnackBar.show(context,
                  title: 'Hata',
                  message: 'Kullanıcı profili bulunamadı!',
                  contentType: ContentType.failure);
            }
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        AwesomeSnackBar.show(context,
            title: 'Hata',
            message: 'Kullanıcı bilgileri alınırken hata oluştu!',
            contentType: ContentType.failure);
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_profileModel == null) {
      AwesomeSnackBar.show(context,
          title: '',
          message: 'Profil verileri yüklenemediği için işlem yapılamıyor.',
          contentType: ContentType.failure);
      return;
    }

    setState(() => isLoading = true);

    final user = _commonRepository.getCurrentUser();

    if (user != null) {
      try {
        final updatedProfile = _profileModel!.copyWith(
          uid: user.uid,
          fullName: _nameController.text.trim(),
          university: _universityController.text.trim(),
          startYear: _startYearController.text.trim(),
          graduationYear: _graduationYearController.text.trim(),
          department: _departmentController.text.trim(),
          studentClass: _classController.text.trim(),
          aboutMe: _aboutController.text.trim(),
        );

        await _profileRepository.updateStudentProfile(updatedProfile);

        setState(() {
          _profileModel = updatedProfile;
          isEditing = false;
        });

        if (mounted) {
          AwesomeSnackBar.show(context,
              title: 'Başarılı',
              message: 'Bilgiler başarıyla kaydedildi!',
              contentType: ContentType.success);
        }
      } catch (e) {
        if (mounted) {
          AwesomeSnackBar.show(context,
              title: 'Hata',
              message:
                  'Bilgiler kaydedilirken bir sorun oluştu! Lütfen tekrar deneyin.',
              contentType: ContentType.failure);
        }
      } finally {
        setState(() {
          setState(() => isLoading = false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_profileModel == null) {
      return const Center(child: Text("Kullanıcı bilgileri yüklenemedi."));
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
            const Text(
              "Kişisel Bilgiler",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              icon: const Icon(
                Icons.edit,
                size: 18,
                color: Colors.blueAccent,
              ),
              label: const Text(
                "Düzenle",
                style: TextStyle(color: Colors.blueAccent),
              ),
            )
          ],
        ),
        const Divider(),
        const SizedBox(height: 10),
        CustomInfoRow(
            icon: Icons.person, value: _nameController.text, label: 'Ad Soyad'),
        CustomInfoRow(
            icon: Icons.school,
            value: _universityController.text,
            label: 'Üniversite'),
        CustomInfoRow(
            icon: Icons.calendar_month,
            value: _startYearController.text,
            label: 'Başlangıç Yılı'),
        CustomInfoRow(
            icon: Icons.calendar_month,
            value: _graduationYearController.text,
            label: 'Bitiş Yılı(Tahmini'),
        CustomInfoRow(
            icon: Icons.book,
            value: _departmentController.text,
            label: 'Bölüm'),
        CustomInfoRow(
            icon: Icons.timeline, value: _classController.text, label: 'Sınıf'),
        const SizedBox(height: 16),
        const Text("Hakkımda",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            _aboutController.text.isNotEmpty
                ? _aboutController.text
                : "Henüz bir bilgi girilmemiş.",
            style: const TextStyle(height: 1.5),
          ),
        ),
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
              const Text("Bilgileri Düzenle",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    if (_profileModel != null) {
                      _populateControllers(_profileModel!);
                    }

                    isEditing = false;
                  });
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
              controller: _nameController,
              icon: Icons.person,
              labelText: 'Ad Soyad'),
          const SizedBox(height: 16),
          CustomTextField(
              controller: _universityController,
              icon: Icons.school,
              labelText: 'Üniversite'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                    controller: _startYearController,
                    icon: Icons.calendar_month,
                    labelText: 'Başlangıç Yılı'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                    controller: _graduationYearController,
                    icon: Icons.calendar_month,
                    labelText: 'Bitiş Yılı(Tahmini)'),
              ),
              const SizedBox(height: 16),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                    controller: _departmentController,
                    icon: Icons.book,
                    labelText: 'Bölüm'),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: CustomTextField(
                      controller: _classController,
                      icon: Icons.timeline,
                      labelText: 'Sınıf')),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
              controller: _aboutController,
              icon: Icons.info_outline,
              labelText: 'Hakkımda',
              maxLines: 4),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      if (_profileModel != null)
                        _populateControllers(_profileModel!);
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
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
