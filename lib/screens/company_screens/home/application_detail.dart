import 'package:flutter/material.dart';
import 'package:staj_bul_demo/core/services/mail_service.dart';
import 'package:staj_bul_demo/models/company_profile_model.dart';
import 'package:staj_bul_demo/repositories/common/application_repository.dart';
import 'package:staj_bul_demo/repositories/company/company_profile_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/awesome_snack_bar.dart';
import 'package:staj_bul_demo/models/application_model.dart';
import 'package:staj_bul_demo/models/student_profile_model.dart';
import 'package:staj_bul_demo/repositories/student/student_profile_repository.dart';

class ApplicationDetailPage extends StatefulWidget {
  final ApplicationModel application;

  const ApplicationDetailPage({super.key, required this.application});

  @override
  State<ApplicationDetailPage> createState() => _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends State<ApplicationDetailPage> {
  final StudentProfileRepository _studentProfileRepo =
      StudentProfileRepository();
  final CompanyProfileRepository _companyProfileRepo =
      CompanyProfileRepository();
  final ApplicationRepository _appRepository = ApplicationRepository();

  StudentProfileModel? _studentProfile;
  CompanyProfileModel? _companyProfile;
  bool _isLoading = true;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.application.status;
    _loadStudentDetailsAndMarkAsReviewed();
  }

  Future<void> _loadStudentDetailsAndMarkAsReviewed() async {
    try {
      final studentProfile = await _studentProfileRepo
          .getStudentProfileModel(widget.application.studentId);
      final companyProfile = await _companyProfileRepo
          .getCompanyProfileModel(widget.application.companyId);
      if (mounted) {
        setState(() {
          _studentProfile = studentProfile;
          _companyProfile = companyProfile;
          _isLoading = false;
        });
      }

      if (_currentStatus == 'Başvuruldu') {
        await _appRepository.updateApplicationStatus(
            widget.application.applicationId, 'İncelendi');
        if (mounted) {
          setState(() {
            _currentStatus = 'İncelendi';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await _appRepository.updateApplicationStatus(
          widget.application.applicationId, newStatus);

      if (_studentProfile != null && _studentProfile!.email != null) {
        MailService().sendStatusMail(
          toEmail: _studentProfile!.email!,
          studentName: widget.application.studentName,
          companyName: _companyProfile!.companyName,
          status: newStatus,
        );
      }

      if (mounted) {
        setState(() {
          _currentStatus = newStatus;
          _isLoading = false;
        });
        AwesomeSnackBar.show(
          context,
          title: 'Başarılı',
          message: 'Başvuru durumu "$newStatus" olarak güncellendi.',
          contentType: ContentType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AwesomeSnackBar.show(
          context,
          title: 'Hata',
          message: 'Durum güncellenirken bir hata oluştu.',
          contentType: ContentType.failure,
        );
      }
    }
  }

  Future<void> _launchCVUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Link açılamadı');
      }
    } catch (e) {
      if (mounted) {
        AwesomeSnackBar.show(
          context,
          title: 'Hata',
          message: 'CV dosyası açılamadı. Link bozuk olabilir.',
          contentType: ContentType.failure,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _studentProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Aday Profili',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blueAccent.withOpacity(0.1),
                          backgroundImage: _studentProfile?.profileImageUrl !=
                                  null
                              ? NetworkImage(_studentProfile!.profileImageUrl!)
                              : null,
                          child: _studentProfile?.profileImageUrl == null
                              ? Text(
                                  widget.application.studentName.isNotEmpty
                                      ? widget.application.studentName[0]
                                          .toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.application.studentName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _studentProfile?.university ??
                              widget.application.studentUniversity,
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600),
                        ),
                        if (_studentProfile?.department != null)
                          Text(
                            _studentProfile!.department!,
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade900, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology,
                                color: Colors.white, size: 28),
                            const SizedBox(width: 8),
                            const Text(
                              'Yapay Zeka Analizi',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.application.matchScore != null &&
                                        widget.application.matchScore! > 0
                                    ? '%${(widget.application.matchScore! * 100).toInt()}'
                                    : '-%',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        if (widget.application.aiExplanation != null &&
                            widget.application.aiExplanation!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: 12),
                          Text(
                            widget.application.aiExplanation!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Hakkında',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    _studentProfile?.aboutMe ??
                        'Öğrenci hakkında bilgi bulunmamaktadır.',
                    style: TextStyle(
                        fontSize: 15, color: Colors.grey.shade800, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text('Yetenekler',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (widget.application.studentSkills.isNotEmpty
                            ? widget.application.studentSkills
                            : ['Belirtilmemiş'])
                        .map((skill) => Chip(
                              label: Text(skill),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade300),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Özgeçmiş (CV)',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      if (widget.application.studentCvUrl != null &&
                          widget.application.studentCvUrl!.isNotEmpty) {
                        _launchCVUrl(widget.application.studentCvUrl!);
                      } else {
                        AwesomeSnackBar.show(
                          context,
                          title: 'Uyarı',
                          message: 'Öğrenci CV yüklememiş.',
                          contentType: ContentType.warning,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf,
                              color: widget.application.studentCvUrl != null
                                  ? Colors.red
                                  : Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            widget.application.studentCvUrl != null
                                ? 'CV\'yi Görüntüle'
                                : 'CV Bulunamadı',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          const Icon(Icons.open_in_new,
                              color: Colors.blueAccent),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
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
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red.shade200),
                        ),
                      ),
                      onPressed: _currentStatus == 'Reddedildi'
                          ? null
                          : () => _updateStatus('Reddedildi'),
                      child: const Text('Reddet',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _currentStatus == 'Kabul Edildi'
                          ? null
                          : () => _updateStatus('Kabul Edildi'),
                      child: const Text('Kabul Et',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
