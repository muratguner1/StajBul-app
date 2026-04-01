import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/awesome_snack_bar.dart';
import 'package:staj_bul_demo/models/post_model.dart';
import 'package:staj_bul_demo/repositories/company/common_repository.dart';
import 'package:staj_bul_demo/repositories/company/post_repository.dart';
import 'package:staj_bul_demo/screens/company_screens/posts/add_edit_post_page.dart';

class CompanyPostsPage extends StatefulWidget {
  const CompanyPostsPage({super.key});

  @override
  State<CompanyPostsPage> createState() => _CompanyPostsPageState();
}

class _CompanyPostsPageState extends State<CompanyPostsPage> {
  final PostRepository _postRepository = PostRepository();
  final CommonRepository _commonRepository = CommonRepository();

  late final String? companyId;
  //late int? applicationCount;

  @override
  void initState() {
    super.initState();
    final user = _commonRepository.getCurrentUser();
    companyId = user?.uid;
  }

  // void _setApplicationCount(){

  // }

  void _showDeleteDialog(PostModel model) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('İlanı Sil', style: TextStyle(color: Colors.red)),
        content: Text(
            '"${model.positionTitle}" ilanını kalıcı olarak silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _postRepository.deletePost(model.postId);

                if (!mounted) return;

                AwesomeSnackBar.show(context,
                    title: 'Başarılı',
                    message: 'İlan başarıyla silindi.',
                    contentType: ContentType.success);
              } catch (e) {
                if (!mounted) return;
                AwesomeSnackBar.show(context,
                    title: 'Hata',
                    message: 'İlan silinirken bir sorun oluştu.',
                    contentType: ContentType.failure);
              }
            },
            child: const Text('Evet, Sil', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  Future<void> _toggleStatus(PostModel model) async {
    try {
      await _postRepository.togglePostStatus(model.postId, model.isActive);

      if (!mounted) return;

      AwesomeSnackBar.show(context,
          title: 'Başarılı',
          message: 'İlan durumu başarıyla değiştirildi.',
          contentType: ContentType.success);
    } catch (e) {
      if (!mounted) return;
      AwesomeSnackBar.show(context,
          title: 'Hata',
          message: 'İlan durumu değiştirilirken bir sorun oluştu.',
          contentType: ContentType.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (companyId == null) {
      return const Scaffold(
          body:
              Center(child: Text("Oturum hatası. Lütfen tekrar giriş yapın.")));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'İlanlarım',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddEditPostPage()));
        },
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Yeni İlan",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: _postRepository.getPostsStream(companyId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text("İlanlar yüklenirken bir hata oluştu."));
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "Henüz hiç ilan yayınlamadınız.",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPostCard(post);
            },
          );
        },
      ),
    );
  }

  Widget _buildPostCard(PostModel model) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    model.positionTitle,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: model.isActive
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    model.isActive ? 'Yayında' : 'Pasif',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: model.isActive
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.work_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(model.workType,
                    style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(width: 16),
                Icon(Icons.location_on_outlined,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(model.location,
                    style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text('Başvuru sayısı: 35463'), //TODO: burayı düzelt sonra
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("Yayına Al:",
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade700)),
                    Switch(
                      value: model.isActive,
                      activeThumbColor: Colors.blueAccent,
                      onChanged: (val) => _toggleStatus(model),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      tooltip: 'Düzenle',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddEditPostPage(model: model)));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Sil',
                      onPressed: () => _showDeleteDialog(model),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
