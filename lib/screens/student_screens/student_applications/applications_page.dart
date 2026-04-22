import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staj_bul_demo/models/application_model.dart';
import 'package:staj_bul_demo/models/post_model.dart';
import 'package:staj_bul_demo/repositories/common/post_repository.dart';
import 'package:staj_bul_demo/repositories/common/application_repository.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/screens/student_screens/student_home/post_detail_page.dart';

class StudentApplicationsPage extends StatefulWidget {
  const StudentApplicationsPage({super.key});

  @override
  State<StudentApplicationsPage> createState() =>
      _StudentApplicationsPageState();
}

class _StudentApplicationsPageState extends State<StudentApplicationsPage> {
  final ApplicationRepository _applicationRepository = ApplicationRepository();
  final CommonRepository _commonRepository = CommonRepository();
  final PostRepository _postRepository = PostRepository();

  @override
  Widget build(BuildContext context) {
    final user = _commonRepository.getCurrentUser();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Başvurularım',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue[500],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('Lütfen giriş yapın'))
          : StreamBuilder<List<ApplicationModel>>(
              stream:
                  _applicationRepository.getStudentApplicationsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final applications = snapshot.data ?? [];

                if (applications.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final app = applications[index];
                    return _buildApplicationCard(app);
                  },
                );
              },
            ),
    );
  }

  Widget _buildApplicationCard(ApplicationModel app) {
    return FutureBuilder<PostModel?>(
      future: _postRepository.getPostById(app.postId),
      builder: (context, postSnapshot) {
        final post = postSnapshot.data;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: post != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailPage(model: post),
                      ),
                    );
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post?.positionTitle ?? 'Yükleniyor...',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              post?.companyName ?? '...',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStatusBadge(app.status),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd.MM.yyyy')
                                .format(app.appliedAt.toDate()),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      if (app.matchScore != null && app.matchScore! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'AI Uyumu: %${(app.matchScore! * 100).toInt()}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Başvuruldu':
        color = Colors.blue;
        break;
      case 'İncelendi':
        color = Colors.orange;
        break;
      case 'Kabul Edildi':
        color = Colors.green;
        break;
      case 'Reddedildi':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Henüz bir başvurun bulunmuyor.',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
