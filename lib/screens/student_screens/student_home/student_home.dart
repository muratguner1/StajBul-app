import 'dart:async'; // Canlı yayın için
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/awesome_snack_bar.dart';
import 'package:staj_bul_demo/core/widgets/student/home_page/build_header.dart';
import 'package:staj_bul_demo/core/widgets/student/home_page/build_profile_completition_card.dart';
import 'package:staj_bul_demo/core/widgets/student/home_page/build_search_bar.dart';
import 'package:staj_bul_demo/models/post_model.dart';
import 'package:staj_bul_demo/models/student_profile_model.dart';
import 'package:staj_bul_demo/repositories/common/post_repository.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/repositories/student/profile_repository.dart';
import 'package:staj_bul_demo/screens/student_screens/student_home/post_detail_page.dart';

class StudentHomePage extends StatefulWidget {
  final VoidCallback onGoToProfile;
  const StudentHomePage({super.key, required this.onGoToProfile});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final CommonRepository _commonRepository = CommonRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  StudentProfileModel? _studentModel;
  double _completionRate = 0.0;
  bool isLoading = true;

  late Stream<List<PostModel>> _postsStream;
  StreamSubscription<StudentProfileModel?>? _profileSubscription;

  String _searchQuery = '';
  String _selectedCategory = 'Tümü';

  @override
  void initState() {
    super.initState();
    _postsStream = PostRepository().getActivePostsStream();
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
          if (student != null && mounted) {
            int totalFields = 5;
            int filledFields = 0;

            if (student.university != null && student.university!.isNotEmpty)
              filledFields++;
            if (student.department != null && student.department!.isNotEmpty)
              filledFields++;
            if (student.aboutMe != null && student.aboutMe!.isNotEmpty)
              filledFields++;
            if (student.skills != null && student.skills!.isNotEmpty)
              filledFields++;
            if (student.cvUrl != null && student.cvUrl!.isNotEmpty)
              filledFields++;

            setState(() {
              _studentModel = student;
              _completionRate = filledFields / totalFields;
              isLoading = false;
            });
          }
        },
        onError: (e) {
          if (mounted) {
            setState(() => isLoading = false);
            AwesomeSnackBar.show(context,
                title: 'Hata',
                message:
                    'Veriler çekilirken bir hata oluştu lütfen tekrar deneyin',
                contentType: ContentType.failure);
          }
        },
      );
    } else {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _toggleSavePost(PostModel model) async {
    if (_studentModel == null) return;

    List<String> currentSavedList =
        List.from(_studentModel!.savedPostIds ?? []);

    bool isSaved = currentSavedList.contains(model.postId);

    if (isSaved) {
      currentSavedList.remove(model.postId);
    } else {
      currentSavedList.add(model.postId);
    }

    final updatedModel =
        _studentModel!.copyWith(savedPostIds: currentSavedList);

    try {
      await _profileRepository.updateStudentProfile(updatedModel);

      AwesomeSnackBar.show(
        context,
        title: 'Başarılı',
        message:
            isSaved ? 'İlan kaydedilenlerden çıkarıldı.' : 'İlan kaydedildi.',
        contentType: ContentType.success,
      );
    } catch (e) {
      AwesomeSnackBar.show(
        context,
        title: 'Hata',
        message: 'İşlem sırasında bir hata oluştu.',
        contentType: ContentType.failure,
      );
    }
  }

  void _showFilterBottomSheet() {
    final List<String> categories = [
      'Tümü',
      'Yazılım',
      'Tasarım',
      'Veri Bilimi',
      'Pazarlama',
      'Mühendislik'
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kategori Filtresi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 12,
                children: categories.map((category) {
                  final isSelected = category == _selectedCategory;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      Navigator.pop(bottomSheetContext);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF2E3A59) : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2E3A59)
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(_studentModel?.fullName.toString() ?? 'Öğrenci'),
                SizedBox(height: 20),
                if (_completionRate < 1.0)
                  buildProfileCompletionCard(
                      context, _completionRate, widget.onGoToProfile),
                SizedBox(height: 20),
                buildSearchBar(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onFilterTap: _showFilterBottomSheet,
                ),
                SizedBox(height: 24),
                Text(
                  'En Yeni İlanlar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                StreamBuilder(
                    stream: _postsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                            child:
                                Text('İlanlar yüklenirken bir hata oluştu.'));
                      }

                      final posts = snapshot.data ?? [];

                      var filteredList = posts;

                      if (_selectedCategory != 'Tümü') {
                        filteredList = filteredList.where((model) {
                          return model.tags.any((tag) =>
                              tag.toLowerCase() ==
                              _selectedCategory.toLowerCase());
                        }).toList();
                      }

                      if (_searchQuery.isNotEmpty) {
                        final query = _searchQuery.toLowerCase();
                        filteredList = filteredList.where((model) {
                          return model.positionTitle
                                  .toLowerCase()
                                  .contains(query) ||
                              model.companyName.toLowerCase().contains(query);
                        }).toList();
                      }

                      if (filteredList.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                                'Aradığınız kriterlere uygun ilan bulunamadı.',
                                style: TextStyle(color: Colors.grey)),
                          ),
                        );
                      }

                      return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final model = filteredList[index];
                            return _buildPostCard(model);
                          });
                    }),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel model) {
    final isSaved =
        _studentModel?.savedPostIds?.contains(model.postId) ?? false;

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
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Colors.blueAccent : Colors.grey,
                    ),
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
