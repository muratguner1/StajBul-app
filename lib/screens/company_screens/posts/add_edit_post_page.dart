import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/awesome_snack_bar.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/custom_section_header.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/custom_text_field.dart';
import 'package:staj_bul_demo/models/post_model.dart';
import 'package:staj_bul_demo/repositories/company/common_repository.dart';
import 'package:staj_bul_demo/repositories/common/post_repository.dart';
import 'package:staj_bul_demo/repositories/company/profile_repository.dart';

class AddEditPostPage extends StatefulWidget {
  final PostModel? model;

  const AddEditPostPage({super.key, this.model});

  @override
  State<AddEditPostPage> createState() => _AddEditPostPageState();
}

class _AddEditPostPageState extends State<AddEditPostPage> {
  final _formKey = GlobalKey<FormState>();
  final PostRepository _postRepository = PostRepository();
  final CommonRepository _commonRepository = CommonRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  bool isLoading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _qualificationsController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String workType = 'Ofis';
  String internshipType = 'Zorunlu Staj';

  final List<String> _workTypeOptions = [
    'Ofis',
    'Uzaktan (Remote)',
    'Hibrit',
  ];
  final List<String> _internshipTypeOptions = [
    'Zorunlu Staj',
    'Gönüllü Staj',
    'Uzun Dönem',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _titleController.text = widget.model!.positionTitle;
      _descriptionController.text = widget.model!.description;
      _qualificationsController.text = widget.model!.qualifications;
      _locationController.text = widget.model!.location;
      _tagsController.text = widget.model!.tags.join(', ');

      if (_workTypeOptions.contains(widget.model!.workType)) {
        workType = widget.model!.workType;
      }
      if (_internshipTypeOptions.contains(widget.model!.internshipType)) {
        internshipType = widget.model!.internshipType;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _qualificationsController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final user = _commonRepository.getCurrentUser();
      if (user == null) throw Exception('Kullanıcı bulunamadı.');

      final profile = await _profileRepository.getCompanyProfileModel(user.uid);
      final String currentCompanyName = profile?.companyName ?? 'Belirtilmedi';
      final String currentLogoUrl = profile?.logoUrl ?? '';

      final List<String> tagList = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (widget.model == null) {
        final newPost = PostModel(
            postId: '',
            companyId: user.uid,
            positionTitle: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            qualifications: _qualificationsController.text.trim(),
            location: _locationController.text.trim(),
            workType: workType,
            internshipType: internshipType,
            tags: tagList,
            createdAt: Timestamp.now(),
            isActive: true,
            companyName: currentCompanyName,
            logoUrl: currentLogoUrl);

        await _postRepository.createPost(newPost);
      } else {
        final updatedPost = widget.model!.copyWith(
          positionTitle: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          qualifications: _qualificationsController.text.trim(),
          location: _locationController.text.trim(),
          workType: workType,
          internshipType: internshipType,
          tags: tagList,
        );

        await _postRepository.updatePosts(updatedPost);
      }

      if (!mounted) return;

      Navigator.pop(context);

      AwesomeSnackBar.show(
        context,
        title: 'Başarılı',
        message: widget.model == null
            ? 'İlan başarıyla yayınlandı!'
            : 'İlan başarıyla güncellendi!',
        contentType: ContentType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      AwesomeSnackBar.show(
        context,
        title: 'Hata',
        message: 'İşlem sırasında bir hata meydana geldi.',
        contentType: ContentType.failure,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.model != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'İlanı Düzenle' : 'Yeni İlan Oluştur',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomSectionHeader(title: 'Temel Bilgiler'),
                    CustomTextField(
                      controller: _titleController,
                      icon: Icons.work_outline,
                      labelText: 'Pozisyon Adı (Örn: Flutter Geliştirici)',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _locationController,
                      icon: Icons.location_city_outlined,
                      labelText: 'Konum (Şehir veya İlçe)',
                    ),
                    const SizedBox(height: 24),
                    const CustomSectionHeader(title: 'Çalışma Detayları'),
                    _buildDropdown('Çalışma Şekli', workType, _workTypeOptions,
                        (val) {
                      setState(() => workType = val!);
                    }),
                    const SizedBox(height: 16),
                    _buildDropdown(
                        'Staj Türü', internshipType, _internshipTypeOptions,
                        (val) {
                      setState(() => internshipType = val!);
                    }),
                    const SizedBox(height: 24),
                    const CustomSectionHeader(title: 'İlan Detayları'),
                    CustomTextField(
                      controller: _descriptionController,
                      icon: Icons.description_outlined,
                      labelText: 'İş Tanımı (Ne yapacaklar?)',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _qualificationsController,
                      icon: Icons.star_border_outlined,
                      labelText: 'Aranan Nitelikler (Kimleri arıyorsunuz?)',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    const CustomSectionHeader(
                        title: 'Etiketler (Arama Kolaylığı İçin)'),
                    CustomTextField(
                      controller: _tagsController,
                      icon: Icons.tag,
                      labelText: 'Örn: Java, Dart, SQL (Virgülle ayırın)',
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _savePost,
                        icon: const Icon(Icons.rocket_launch,
                            color: Colors.white),
                        label: Text(
                          isEditing ? 'Değişiklikleri Kaydet' : 'İlanı Yayınla',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown(String label, String currentValue, List<String> options,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField(
      initialValue: currentValue,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: options.map((String option) {
        return DropdownMenuItem<String>(value: option, child: Text(option));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
