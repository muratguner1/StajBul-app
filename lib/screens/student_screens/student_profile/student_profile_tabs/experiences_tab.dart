import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staj_bul_demo/models/experience_model.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/repositories/student/student_profile_repository.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/awesome_snack_bar.dart';

class ExperiencesTab extends StatefulWidget {
  const ExperiencesTab({super.key});

  @override
  State<ExperiencesTab> createState() => _ExperiencesTabState();
}

class _ExperiencesTabState extends State<ExperiencesTab>
    with AutomaticKeepAliveClientMixin {
  final StudentProfileRepository _profileRepository =
      StudentProfileRepository();
  final CommonRepository _commonRepository = CommonRepository();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrentlyWorking = false;
  bool isLoading = false;
  String? _dateError;

  @override
  bool get wantKeepAlive => true;

  void _resetForm() {
    _companyController.clear();
    _positionController.clear();
    _descriptionController.clear();

    setState(() {
      _startDate = null;
      _endDate = null;
      _isCurrentlyWorking = false;
      _dateError = null;
    });
  }

  bool _validateDates() {
    if (_isCurrentlyWorking) {
      setState(() => _dateError = null);
      return true;
    }

    if (_startDate != null && _endDate != null) {
      if (_endDate!.isBefore(_startDate!)) {
        setState(() => _dateError = 'Bitiş tarihi başlangıçtan önce olamaz.');
        return false;
      }
    }

    setState(() => _dateError = null);
    return true;
  }

  Future<void> _saveExperience({String? docId}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      setState(() => _dateError = "Başlangıç tarihi seçmelisiniz.");
      return;
    }

    if (!_validateDates()) return;

    final user = _commonRepository.getCurrentUser();
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      final experience = ExperienceModel(
          id: docId ?? '',
          company: _companyController.text.trim(),
          position: _positionController.text.trim(),
          description: _descriptionController.text.trim(),
          startDate: _startDate!,
          endDate: _isCurrentlyWorking ? null : _endDate,
          isCurrent: _isCurrentlyWorking);

      await _profileRepository.saveExperience(user.uid, experience);

      if (mounted) {
        Navigator.pop(context);
        _resetForm();
      }

      AwesomeSnackBar.show(
        context,
        title: 'Başarılı',
        message: 'Deneyim kaydedildi.',
        contentType: ContentType.success,
      );
    } catch (e) {
      if (mounted) {
        AwesomeSnackBar.show(context,
            title: 'Hata',
            message: "Kaydedilirken bir sorun oluştu. Lütfen tekrar deneyin.",
            contentType: ContentType.failure);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _deleteExperience(String docId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Deneyimi Sil',
          style: TextStyle(
              color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: const Text('Bu deneyimi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'İptal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final user = _commonRepository.getCurrentUser();
      if (user == null) return;

      await _profileRepository.deleteExperience(user.uid, docId);

      if (mounted) {
        AwesomeSnackBar.show(
          context,
          title: 'Başarılı',
          message: 'Deneyim silindi.',
          contentType: ContentType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AwesomeSnackBar.show(context,
            title: 'Hata',
            message: "Silinirken bir sorun oluştu. Lütfen tekrar deneyin.",
            contentType: ContentType.failure);
      }
    }
  }

  void _showExperienceForm({ExperienceModel? experience}) {
    if (experience != null) {
      _companyController.text = experience.company;
      _positionController.text = experience.position;
      _descriptionController.text = experience.description;
      _startDate = experience.startDate;
      _endDate = experience.endDate;
      _isCurrentlyWorking = experience.isCurrent;
      _dateError = null;
    } else {
      _resetForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience == null ? 'Deneyim Ekle' : 'Deneyimi Düzenle',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyController,
                    decoration: _inputDecoration('Şirket Adı'),
                    validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _positionController,
                    decoration: _inputDecoration('Pozisyon / Unvan'),
                    validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.grey.shade50,
                            alignment: Alignment.centerLeft,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade400)),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              _startDate = picked;
                              _validateDates();
                              setModalState(() {});
                            }
                          },
                          label: Text(
                            _startDate == null
                                ? 'Başlangıç'
                                : DateFormat('MM/yyyy').format(_startDate!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _isCurrentlyWorking
                            ? Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.green.shade200)),
                                child: const Center(
                                    child: Text('Devam Ediyor',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold))))
                            : TextButton.icon(
                                icon: const Icon(Icons.calendar_today_outlined),
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.grey.shade50,
                                  alignment: Alignment.centerLeft,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                          color: Colors.grey.shade400)),
                                ),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    _endDate = picked;
                                    _validateDates();
                                    setModalState(() {});
                                  }
                                },
                                label: Text(
                                  _endDate == null
                                      ? 'Bitiş'
                                      : DateFormat('MM/yyyy').format(_endDate!),
                                  style: TextStyle(
                                      color: _endDate == null
                                          ? Colors.grey.shade600
                                          : Colors.black87),
                                ),
                              ),
                      ),
                    ],
                  ),
                  if (_dateError != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsetsGeometry.only(left: 4),
                      child: Text(
                        _dateError!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                  CheckboxListTile(
                    title: const Text('Bu görevde hala çalışıyorum'),
                    value: _isCurrentlyWorking,
                    onChanged: (val) {
                      setModalState(() {
                        _isCurrentlyWorking = val!;
                        if (_isCurrentlyWorking) {
                          _endDate = null;
                          _dateError = null;
                        }
                        setModalState(() {});
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: _inputDecoration('Açıklama (Opsiyonel)'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _saveExperience(docId: experience?.id),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white),
                      child: Text(experience == null ? 'Ekle' : 'Güncelle'),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = _commonRepository.getCurrentUser();
    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExperienceForm(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<ExperienceModel>>(
        stream: _profileRepository.getAllExperiences(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final experiences = snapshot.data ?? [];
          if (experiences.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.work_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  const Text(
                    'Henüz deneyim eklenmemiş.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () => _showExperienceForm(),
                    child: const Text("İlk Deneyimini Ekle"),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: experiences.length,
              itemBuilder: (context, index) {
                final experience = experiences[index];

                final dateStr =
                    '${DateFormat('MM/yyyy').format(experience.startDate)} - ${experience.isCurrent ? 'Devam' : (experience.endDate != null ? DateFormat('MM/yyyy').format(experience.endDate!) : '?')}';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(
                                Icons.business,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    experience.position,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    experience.company,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showExperienceForm(experience: experience);
                                }
                                if (value == 'delete') {
                                  _deleteExperience(experience.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Düzenle')
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete,
                                          color: Colors.red, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Sil',
                                        style: TextStyle(color: Colors.red),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (experience.description.isNotEmpty) ...[
                          const Divider(height: 20),
                          Text(
                            experience.description,
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 13),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              });
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14));
  }
}
