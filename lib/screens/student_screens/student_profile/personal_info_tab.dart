import 'package:flutter/material.dart';
import 'package:staj_bul_demo/models/student_profile_model.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/repositories/student/profile_repository.dart';
import 'package:staj_bul_demo/widgets/custom_widgets/awesome_snack_bar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:staj_bul_demo/widgets/custom_widgets/build_info_row.dart';
import 'package:staj_bul_demo/widgets/custom_widgets/build_text_filed.dart';

class PersonalInfoTab extends StatefulWidget {
  const PersonalInfoTab({super.key});

  @override
  State<PersonalInfoTab> createState() => _PersonalInfoTabState();
}

class _PersonalInfoTabState extends State<PersonalInfoTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final CommonRepository _commonRepository = CommonRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
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
        buildInfoRow(Icons.person, "Ad Soyad", _nameController.text),
        buildInfoRow(Icons.school, "Üniversite", _universityController.text),
        buildInfoRow(
            Icons.calendar_month, "Başlangıç Yılı", _startYearController.text),
        buildInfoRow(Icons.calendar_month, "Bitiş Yılı(Tahmini)",
            _graduationYearController.text),
        buildInfoRow(Icons.book, "Bölüm", _departmentController.text),
        buildInfoRow(Icons.timeline, "Sınıf", _classController.text),
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
                    if (_profileModel != null)
                      _populateControllers(_profileModel!);
                    isEditing = false;
                  });
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          buildTextField("Ad Soyad", _nameController, Icons.person),
          const SizedBox(height: 16),
          buildTextField("Üniversite", _universityController, Icons.school),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: buildTextField("Başlangıç Yılı", _startYearController,
                    Icons.calendar_month),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: buildTextField("Bitiş Yılı(Tahmini)",
                    _graduationYearController, Icons.calendar_month),
              ),
              const SizedBox(height: 16),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: buildTextField(
                      "Bölüm", _departmentController, Icons.book)),
              const SizedBox(width: 16),
              Expanded(
                  child: buildTextField(
                      "Sınıf", _classController, Icons.timeline)),
            ],
          ),
          const SizedBox(height: 16),
          buildTextField("Hakkımda", _aboutController, Icons.info_outline,
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
