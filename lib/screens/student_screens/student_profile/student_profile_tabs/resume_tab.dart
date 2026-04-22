import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/repositories/student/profile_repository.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/awesome_snack_bar.dart';
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

  Future<void> _pickAndUploadCV() async {
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
    TextEditingController nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("CV'ni İsimlendir"),
          content: TextField(
            controller: nameController,
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
                  Navigator.pop(context, nameController.text.trim()),
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
      await _profileRepository.uploadResume(
          user.uid, fileName, file, customName);

      if (!mounted) return;
      AwesomeSnackBar.show(context,
          title: 'Başarılı',
          message: 'CV başarıyla yüklendi',
          contentType: ContentType.success);
    } catch (e) {
      if (!mounted) return;
      AwesomeSnackBar.show(context,
          title: 'Hata',
          message: 'Yükleme hatası',
          contentType: ContentType.failure);
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Future<void> _deleteResume(String storagePath) async {
    setState(() => isUploading = true);
    final user = _commonRepository.getCurrentUser();
    if (user == null) return;

    try {
      await _profileRepository.deleteResume(storagePath, user.uid);
    } catch (e) {
      if (!mounted) return;
      AwesomeSnackBar.show(context,
          title: 'Hata',
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
          title: 'Hata',
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

        Map<String, dynamic>? resumeData;

        if (snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data['resumeData'] != null) {
            resumeData = data['resumeData'] as Map<String, dynamic>;
          }
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (resumeData == null)
                InkWell(
                  onTap: isUploading ? null : _pickAndUploadCV,
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
                          const Text("Özgeçmiş (PDF) Yükle",
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold)),
                          Text("0/1 Dolu",
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                        ]
                      ],
                    ),
                  ),
                )
              else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Center(
                    child: Text(
                      "Maksimum CV sayısına ulaştınız (1/1). Yeni yükleme yapmak için mevcut CV'nizi silmelisiniz.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf,
                        color: Colors.redAccent, size: 32),
                    title: Text(resumeData['name'] ?? 'İsimsiz CV',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "Yüklenme: ${DateFormat('dd/MM/yyyy').format((resumeData['uploadedAt'] as Timestamp).toDate())}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility,
                              color: Colors.blueGrey),
                          onPressed: () => _openResume(resumeData!['url']),
                          tooltip: "Görüntüle",
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () =>
                              _deleteResume(resumeData!['storagePath']),
                          tooltip: "Sil",
                        ),
                      ],
                    ),
                  ),
                )
              ]
            ],
          ),
        );
      },
    );
  }
}
