import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/repositories/student_profile_repository.dart';
import 'package:staj_bul_demo/widgets/custom_widgets/awesome_snack_bar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ExperiencesTab extends StatefulWidget {
  const ExperiencesTab({super.key});

  @override
  State<ExperiencesTab> createState() => _ExperiencesTabState();
}

class _ExperiencesTabState extends State<ExperiencesTab> {
  final StudentProfileRepository _repository = StudentProfileRepository();
  final CommonRepository _commonRepository = CommonRepository();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrentlyWorking = false;
  bool isLoading = false;

  void _resetForm() {
    _companyController.clear();
    _positionController.clear();
    _descriptionController.clear();

    setState(() {
      _startDate = null;
      _endDate = null;
      _isCurrentlyWorking = false;
    });
  }

  Future<void> _saveExperience({String? docId}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      AwesomeSnackBar.show(context,
          title: '',
          message: "Başlangıç tarihi seçmelisiniz.",
          contentType: ContentType.failure);
    }

    final user = _commonRepository.getCurrentUser();
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      final data = {
        'company': _companyController.text.trim(),
        'position': _positionController.text.trim(),
        'description': _descriptionController.text.trim(),
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': _isCurrentlyWorking
            ? null
            : (_endDate != null ? Timestamp.fromDate(_endDate!) : null),
        'isCurrent': _isCurrentlyWorking,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final collectionRef = _repository.getInnerCollection(
          user.uid, FirestoreCollections.experiences);

      if (docId == null) {
        await collectionRef.add(data);
      } else {
        await collectionRef.doc(docId).update(data);
      }

      Navigator.pop(context);
      _resetForm();
    } catch (e) {
      print('Hata: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteExperience(String docId) async {
    final user = _commonRepository.getCurrentUser();
    if (user == null) return;

    _repository.deleteExperience(user.uid, docId);
  }

  void _showExperienceForm({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _companyController.text = data['company'];
      _positionController.text = data['position'];
      _descriptionController.text = data['description'] ?? '';
      _startDate = (data['startDate'] as Timestamp).toDate();
      _endDate = data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null;
      _isCurrentlyWorking = data['isCurrent'] ?? false;
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
                children: [
                  Text(
                    doc == null ? 'Deneyim Ekle' : 'Deneyimi Düzenle',
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
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() => _startDate = picked);
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
                            ? const Center(
                                child: Text('Devam Ediyor',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold)))
                            : TextButton.icon(
                                icon: const Icon(Icons.calendar_today_outlined),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setModalState(() => _endDate = picked);
                                  }
                                },
                                label: Text(
                                  _endDate == null
                                      ? 'Bitiş'
                                      : DateFormat('MM/yyyy').format(_endDate!),
                                ),
                              ),
                      ),
                    ],
                  ),
                  CheckboxListTile(
                    title: const Text('Bu görevde hala çalışıyorum'),
                    value: _isCurrentlyWorking,
                    onChanged: (val) {
                      setModalState(() {
                        _isCurrentlyWorking = val!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
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
                      onPressed: () => _saveExperience(docId: doc?.id),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white),
                      child: Text(doc == null ? 'Ekle' : 'Güncelle'),
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
    final user = _commonRepository.getCurrentUser();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExperienceForm(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _repository.getAllExperiences(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
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
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final docId = docs[index].id;

                final start = (data['startDate'] as Timestamp).toDate();
                final end = data['endDate'] != null
                    ? (data['endDate'] as Timestamp).toDate()
                    : null;
                final isCurrent = data['isCurrent'] ?? false;

                final dateSrt =
                    '${DateFormat('MM/yyyy').format(start)} - ${isCurrent ? 'Devam' : (end != null ? DateFormat('MM/yyyy').format(end) : '?')}';

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
                                    data['position'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    data['company'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateSrt,
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
                                  _showExperienceForm(doc: docs[index]);
                                }
                                if (value == 'delete') _deleteExperience(docId);
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
                        if (data['description'] != null &&
                            data['description'].toString().isNotEmpty) ...[
                          const Divider(height: 20),
                          Text(
                            data['description'],
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
