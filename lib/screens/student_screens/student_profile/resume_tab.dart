import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/repositories/student/profile_repository.dart';
import 'package:staj_bul_demo/widgets/custom_widgets/awesome_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class ResumeTab extends StatefulWidget {
  const ResumeTab({super.key});

  @override
  State<ResumeTab> createState() => _ResumeTabState();
}

class _ResumeTabState extends State<ResumeTab>
    with AutomaticKeepAliveClientMixin {
  final ProfileRepository _profileRepository = ProfileRepository();
  final CommonRepository _commonRepository = CommonRepository();
  bool isUploading = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _pickAndUploadCV(int currentCount) async {
    if (currentCount >= 2) {
      AwesomeSnackBar.show(context,
          title: '',
          message: 'En fazla 2 adet CV yükleyebilirsiniz.',
          contentType: ContentType.failure);
      return;
    }

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final File file = File(result.files.single.path!);

      String? customName = await _showNameDialog();

      if (customName == null || customName.isEmpty) return;

      await _uploadToStorage(file, customName);
    }
  }

  Future<String?> _showNameDialog() async {
    TextEditingController _nameContorller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("CV'ni İsimlendir"),
          content: TextField(
            controller: _nameContorller,
            decoration: const InputDecoration(
                hintText: "Örn: Yazılım CV'im", border: OutlineInputBorder()),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, _nameContorller.text.trim()),
              child: const Text('Yükle'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadToStorage(File file, String customName) async {
    setState(() => isUploading = true);
    final user = _commonRepository.getCurrentUser();
    if (user == null) return;

    try {
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.pdf";

      _profileRepository.uploadResume(user.uid, fileName, file, customName);

      if (!mounted) return;
      AwesomeSnackBar.show(context,
          title: '',
          message: 'CV başarıyla yüklendi',
          contentType: ContentType.success);
    } catch (e) {
      if (!mounted) return;
      AwesomeSnackBar.show(context,
          title: '',
          message: 'Yükleme hatası',
          contentType: ContentType.failure);
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Future<void> _deleteResume(Map<String, dynamic> resumeItem) async {
    setState(() => isUploading = true);

    final user = _commonRepository.getCurrentUser();

    if (user == null) return;

    try {
      _profileRepository.deleteResume(resumeItem, user.uid);
    } catch (e) {
      if (!mounted) return;
      AwesomeSnackBar.show(context,
          title: '',
          message: 'Silinirken hata oluştu!',
          contentType: ContentType.failure);
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Future<void> _openResume(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      AwesomeSnackBar.show(context,
          title: '',
          message: 'PDF açılamadı',
          contentType: ContentType.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = _commonRepository.getCurrentUser();

    return StreamBuilder<DocumentSnapshot>(
      stream: _commonRepository.getStudentProfileStream(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Hata oluştu');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        List<dynamic> resumes = [];

        if (snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data['resumes'] != null) {
            resumes = data['resumes'] as List<dynamic>;
          }
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (resumes.length < 2)
                InkWell(
                  onTap: isUploading
                      ? null
                      : () => _pickAndUploadCV(resumes.length),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.blueAccent,
                          style: BorderStyle.values[1]),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue.shade50,
                    ),
                    child: Column(
                      children: [
                        if (isUploading)
                          const CircularProgressIndicator()
                        else ...[
                          const Icon(Icons.cloud_upload_outlined,
                              size: 40, color: Colors.blueAccent),
                          const SizedBox(height: 8),
                          const Text("Yeni Özgeçmiş (PDF) Yükle",
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold)),
                          Text("${resumes.length}/2 Dolu",
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                        ]
                      ],
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Center(
                    child: Text(
                      "Maksimum CV sayısına ulaştınız (2/2).",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              if (resumes.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "Henüz CV yüklenmemiş.",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                Expanded(
                    child: ListView.builder(
                  itemCount: resumes.length,
                  itemBuilder: (context, index) {
                    final resume = resumes[index] as Map<String, dynamic>;
                    final Timestamp? date = resume['uploadedAt'];
                    final dateStr = date != null
                        ? DateFormat('dd/MM/yyyy').format(date.toDate())
                        : '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.picture_as_pdf,
                            color: Colors.redAccent, size: 32),
                        title: Text(resume['name'] ?? 'İsimsiz CV',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Yüklenme: $dateStr"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility,
                                  color: Colors.blueGrey),
                              onPressed: () => _openResume(resume['url']),
                              tooltip: "Görüntüle",
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => _deleteResume(resume),
                              tooltip: "Sil",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ))
            ],
          ),
        );
      },
    );
  }
}
