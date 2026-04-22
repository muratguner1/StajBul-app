import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staj_bul_demo/models/application_model.dart';
import 'package:staj_bul_demo/models/post_model.dart';
import 'package:staj_bul_demo/repositories/common/application_repository.dart';
import 'package:staj_bul_demo/screens/company_screens/home/application_detail.dart';

class CompanyPostDetailsPage extends StatefulWidget {
  final PostModel post;
  const CompanyPostDetailsPage({super.key, required this.post});

  @override
  State<CompanyPostDetailsPage> createState() => _CompanyPostDetailsPageState();
}

class _CompanyPostDetailsPageState extends State<CompanyPostDetailsPage> {
  final ApplicationRepository _appRepository = ApplicationRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('İlan Detayı ve Başvurular',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ÜST KISIM: İLAN ÖZETİ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.positionTitle,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(widget.post.location,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 16),
                    const Icon(Icons.work_outline,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(widget.post.workType,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.post.tags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(tag,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.blueAccent)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ALT KISIM: BAŞVURANLAR LİSTESİ
          Expanded(
            child: StreamBuilder<List<ApplicationModel>>(
              stream:
                  _appRepository.getPostApplicationsStream(widget.post.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final applications = snapshot.data ?? [];

                if (applications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('Bu ilana henüz başvuru yapılmamış.',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Başvuranlar (${applications.length})',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: applications.length,
                        itemBuilder: (context, index) {
                          final app = applications[index];
                          return _buildApplicationTile(app);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationTile(ApplicationModel app) {
    final String formattedDate =
        DateFormat('dd.MM.yyyy HH:mm').format(app.appliedAt.toDate());

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          child: Text(
            app.studentName.isNotEmpty ? app.studentName[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(app.studentName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(formattedDate, style: const TextStyle(fontSize: 12)),
        trailing: _buildStatusIndicator(app.status),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApplicationDetailPage(application: app),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color = Colors.grey;
    if (status == 'Başvuruldu') color = Colors.blue;
    if (status == 'İncelendi') color = Colors.orange;
    if (status == 'Kabul Edildi') color = Colors.green;
    if (status == 'Reddedildi') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
