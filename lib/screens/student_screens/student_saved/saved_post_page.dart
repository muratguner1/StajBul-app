import 'dart:async';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/models/post_model.dart';
import 'package:staj_bul_demo/models/student_profile_model.dart';
import 'package:staj_bul_demo/repositories/common/post_repository.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/repositories/student/profile_repository.dart';
import 'package:staj_bul_demo/screens/student_screens/student_home/post_detail_page.dart';

class SavedPostsPage extends StatefulWidget {
  const SavedPostsPage({super.key});

  @override
  State<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  final CommonRepository _commonRepository = CommonRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final PostRepository _postRepository = PostRepository();

  StudentProfileModel? _studentModel;
  bool _isLoading = true;
  late Stream<List<PostModel>> _postsStream;
  StreamSubscription<StudentProfileModel?>? _profileSubscription;

  @override
  void initState() {
    super.initState();
    _postsStream = _postRepository.getActivePostsStream();
    _listenToStudentData();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  void _listenToStudentData() {
    final user = _commonRepository.getCurrentUser();
    if (user != null) {
      _profileSubscription =
          _profileRepository.getStudentProfileStream(user.uid).listen(
        (student) {
          if (mounted) {
            setState(() {
              _studentModel = student;
              _isLoading = false;
            });
          }
        },
        onError: (e) {
          if (mounted) setState(() => _isLoading = false);
        },
      );
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSavePost(PostModel model) async {
    if (_studentModel == null) return;

    List<String> currentSavedList =
        List.from(_studentModel!.savedPostIds ?? []);

    if (currentSavedList.contains(model.postId)) {
      currentSavedList.remove(model.postId);

      final updatedModel =
          _studentModel!.copyWith(savedPostIds: currentSavedList);

      try {
        await _profileRepository.updateStudentProfile(updatedModel);
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Kaydedilen İlanlar',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue[500],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: StreamBuilder<List<PostModel>>(
            stream: _postsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !_isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(
                    child: Text('İlanlar yüklenirken bir hata oluştu.'));
              }

              final allActivePosts = snapshot.data ?? [];
              final savedPostIds = _studentModel?.savedPostIds ?? [];

              final savedPosts = allActivePosts.where((post) {
                return savedPostIds.contains(post.postId);
              }).toList();

              if (savedPosts.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: savedPosts.length,
                itemBuilder: (context, index) {
                  final model = savedPosts[index];
                  return _buildPostCard(model);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Henüz hiç ilan kaydetmedin.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        const Text(
          'İlgini çeken ilanları kaydederek\ndaha sonra kolayca başvurabilirsin.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPostCard(PostModel model) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailPage(model: model),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade50,
                    backgroundImage:
                        (model.logoUrl != null && model.logoUrl!.isNotEmpty)
                            ? NetworkImage(model.logoUrl!)
                            : null,
                    child: (model.logoUrl == null || model.logoUrl!.isEmpty)
                        ? const Icon(Icons.business, color: Colors.blue)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.positionTitle,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          model.companyName,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(model.location,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 13)),
                      const SizedBox(width: 16),
                      Icon(Icons.work_outline,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(model.workType,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(Icons.bookmark, color: Colors.blueAccent),
                    onPressed: () => _toggleSavePost(model),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
