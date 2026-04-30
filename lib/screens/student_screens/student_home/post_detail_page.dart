import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:staj_bul_demo/models/post_model.dart';
import 'package:staj_bul_demo/models/student_profile_model.dart';
import 'package:staj_bul_demo/models/application_model.dart';
import 'package:staj_bul_demo/repositories/common/application_repository.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/repositories/student/student_profile_repository.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/awesome_snack_bar.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel model;
  const PostDetailPage({super.key, required this.model});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final ApplicationRepository _appRepository = ApplicationRepository();
  final StudentProfileRepository _profileRepository =
      StudentProfileRepository();
  final CommonRepository _commonRepository = CommonRepository();

  String? _applicationStatus;
  bool _isLoading = true;
  StudentProfileModel? _studentModel;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final user = _commonRepository.getCurrentUser();
    if (user == null) return;

    try {
      final results = await Future.wait([
        _profileRepository.getStudentProfileModel(user.uid),
        _appRepository.getApplicationStatusForPost(
            widget.model.postId, user.uid)
      ]);

      if (mounted) {
        setState(() {
          _studentModel = results[0] as StudentProfileModel?;
          _applicationStatus = results[1] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleApply() async {
    if (_studentModel == null) {
      if (mounted) {
        AwesomeSnackBar.show(context,
            title: 'Hata',
            message:
                'Öğrenci profiliniz bulunamadı. Lütfen profilinizi tamamlayın.',
            contentType: ContentType.warning);
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String appId = const Uuid().v4();

      final application = ApplicationModel(
        applicationId: appId,
        postId: widget.model.postId,
        companyId: widget.model.companyId,
        studentId: _studentModel!.uid,
        status: "Başvuruldu",
        appliedAt: Timestamp.now(),
        studentName: _studentModel!.fullName,
        studentUniversity: _studentModel!.university ?? 'Belirtilmemiş',
        matchScore: 0.0,
        studentSkills: _studentModel!.skills ?? [],
        studentCvUrl: _studentModel!.cvUrl,
      );

      await _appRepository.applyToPost(application);
      await _appRepository.calculateAndSaveAIScore(
          application, widget.model, _studentModel!);

      setState(() {
        _applicationStatus = "Başvuruldu";
        _isLoading = false;
      });

      if (mounted) {
        AwesomeSnackBar.show(context,
            title: 'Başarılı',
            message: 'Başvurunuz firmaya başarıyla iletildi!',
            contentType: ContentType.success);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AwesomeSnackBar.show(context,
            title: 'Hata',
            message: 'Başvuru sırasında bir hata oluştu.',
            contentType: ContentType.failure);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Başvuruldu':
        return Colors.blue;
      case 'İncelendi':
        return Colors.orange;
      case 'Kabul Edildi':
        return Colors.green;
      case 'Reddedildi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _studentModel == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.shade50,
                          backgroundImage: (widget.model.logoUrl != null &&
                                  widget.model.logoUrl!.isNotEmpty)
                              ? NetworkImage(widget.model.logoUrl!)
                              : null,
                          child: (widget.model.logoUrl == null ||
                                  widget.model.logoUrl!.isEmpty)
                              ? const Icon(Icons.business,
                                  size: 40, color: Colors.blue)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.model.positionTitle,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.model.companyName,
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoChip(
                          Icons.location_on_outlined, widget.model.location),
                      _buildInfoChip(Icons.work_outline, widget.model.workType),
                      _buildInfoChip(
                          Icons.timer_outlined, widget.model.internshipType),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text("İş Tanımı",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    widget.model.description,
                    style: TextStyle(
                        fontSize: 15, color: Colors.grey.shade800, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text("Aranan Nitelikler",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    widget.model.qualifications,
                    style: TextStyle(
                        fontSize: 15, color: Colors.grey.shade800, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.model.tags
                        .map((tag) => Chip(
                              label: Text(tag,
                                  style: const TextStyle(fontSize: 12)),
                              backgroundColor: Colors.grey.shade100,
                              side: BorderSide.none,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _applicationStatus != null
                      ? _getStatusColor(_applicationStatus!)
                      : const Color(0xFF2E3A59),
                  disabledBackgroundColor: _applicationStatus != null
                      ? _getStatusColor(_applicationStatus!)
                      : Colors.grey,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: (_applicationStatus != null || _isLoading)
                    ? null
                    : _handleApply,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        _applicationStatus ?? "Hemen Başvur",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
