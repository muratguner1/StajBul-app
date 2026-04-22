import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/custom_section_header.dart';
import 'package:staj_bul_demo/models/application_model.dart';
import 'package:staj_bul_demo/models/post_model.dart';
import 'package:staj_bul_demo/repositories/common/application_repository.dart';
import 'package:staj_bul_demo/repositories/common/post_repository.dart';
import 'package:staj_bul_demo/repositories/company/common_repository.dart';
import 'package:staj_bul_demo/repositories/company/profile_repository.dart';
import 'package:staj_bul_demo/screens/company_screens/home/application_detail.dart';
import 'package:staj_bul_demo/screens/company_screens/posts/add_edit_post_page.dart';

class CompanyHomePage extends StatefulWidget {
  const CompanyHomePage({super.key});

  @override
  State<CompanyHomePage> createState() => _CompanyHomePageState();
}

class _CompanyHomePageState extends State<CompanyHomePage> {
  final CommonRepository _commonRepository = CommonRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final PostRepository _postRepository = PostRepository();
  final ApplicationRepository _appRepository = ApplicationRepository();

  String _companyName = "Şirket";
  bool _isLoading = true;
  String? _companyId;

  late Stream<List<ApplicationModel>> _applicationsStream;

  @override
  void initState() {
    super.initState();
    final user = _commonRepository.getCurrentUser();
    _companyId = user?.uid;

    if (_companyId != null) {
      _applicationsStream =
          _appRepository.getCompanyApplicationsStream(_companyId!);
    } else {
      _applicationsStream = const Stream.empty();
    }

    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    try {
      final user = _commonRepository.getCurrentUser();
      if (user != null) {
        final profileModel =
            await _profileRepository.getCompanyProfileModel(user.uid);
        if (profileModel != null && mounted) {
          setState(() {
            _companyName = profileModel.companyName;
          });
        }
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrol Paneli',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hoş Geldin,",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              _companyName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CustomSectionHeader(title: 'Genel Bakış'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<int>(
                    stream: _companyId != null
                        ? _postRepository.getActivePostCountStream(_companyId!)
                        : const Stream.empty(),
                    builder: (context, snapshot) {
                      final activeCount = snapshot.data ?? 0;
                      return _buildStatCard(Icons.work_outline, 'Aktif İlan',
                          activeCount.toString(), Colors.orange);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<List<ApplicationModel>>(
                    stream: _applicationsStream,
                    builder: (context, snapshot) {
                      final allApps = snapshot.data ?? [];
                      final pendingCount = allApps
                          .where((app) => app.status == 'Başvuruldu')
                          .length;

                      return _buildStatCard(
                          Icons.people_outline,
                          'Bekleyen Başvuru',
                          pendingCount.toString(),
                          Colors.green);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const CustomSectionHeader(title: 'Hızlı İşlemler'),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddEditPostPage()));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 32),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Yeni İlan Yayınla",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text("Hemen stajyer aramaya başla",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const CustomSectionHeader(title: 'Son Başvurular'),
            const SizedBox(height: 8),
            StreamBuilder<List<ApplicationModel>>(
              stream: _applicationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final applications = snapshot.data ?? [];

                if (applications.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('Henüz hiç başvuru almadınız.',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                final recentApplications = applications.take(4).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentApplications.length,
                  itemBuilder: (context, index) {
                    final app = recentApplications[index];
                    return _buildRecentApplicationTile(app);
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      IconData icon, String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(count,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildRecentApplicationTile(ApplicationModel app) {
    final String formattedDate =
        DateFormat('dd.MM.yyyy HH:mm').format(app.appliedAt.toDate());

    return FutureBuilder<PostModel?>(
      future: _postRepository.getPostById(app.postId),
      builder: (context, snapshot) {
        String postTitle = "Yükleniyor...";

        if (snapshot.connectionState == ConnectionState.done) {
          postTitle = snapshot.data?.positionTitle ?? "Bilinmeyen İlan";
        }

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              child: Text(
                  app.studentName.isNotEmpty
                      ? app.studentName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
            title: Text(app.studentName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$postTitle ilanına başvurdu. ($formattedDate)'),
            trailing: _buildStatusIndicator(app.status),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ApplicationDetailPage(application: app)));
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color = Colors.grey;
    if (status == 'Başvuruldu') color = Colors.blue;
    if (status == 'İncelendi') color = Colors.orange;
    if (status == 'Kabul Edildi') color = Colors.green;
    if (status == 'Reddedildi') color = Colors.red;

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
