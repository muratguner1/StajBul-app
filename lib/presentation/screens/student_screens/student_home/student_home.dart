import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/core/widgets/custom_widgets/awesome_snack_bar.dart';
import 'package:staj_bul_demo/core/widgets/student/home_page/build_header.dart';
import 'package:staj_bul_demo/core/widgets/student/home_page/build_profile_completition_card.dart';
import 'package:staj_bul_demo/core/widgets/student/home_page/build_search_bar.dart';
import 'package:staj_bul_demo/data/models/post_model.dart';
import 'package:staj_bul_demo/data/models/student_profile_model.dart';
import 'package:staj_bul_demo/data/repositories/common/post_repository.dart';
import 'package:staj_bul_demo/data/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/data/repositories/student/student_profile_repository.dart';
import 'package:staj_bul_demo/presentation/screens/student_screens/student_home/post_detail_page.dart';
import 'package:staj_bul_demo/core/constants/category_constants.dart';

class StudentHomePage extends StatefulWidget {
  final VoidCallback onGoToProfile;
  const StudentHomePage({super.key, required this.onGoToProfile});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final CommonRepository _commonRepository = CommonRepository();
  final StudentProfileRepository _profileRepository =
      StudentProfileRepository();

  StudentProfileModel? _studentModel;
  double _completionRate = 0.0;
  bool isLoading = true;

  late Stream<List<PostModel>> _postsStream;
  StreamSubscription<StudentProfileModel?>? _profileSubscription;

  String _searchQuery = '';
  String _selectedCategory = 'Tümü';
  String _selectedWorkType = 'Tümü';
  String _selectedInternshipType = 'Tümü';
  String _selectedLocation = 'Tümü';
  List<PostModel> _allPosts = [];

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
    final List<String> workTypes = ['Tümü', 'Ofis', 'Uzaktan', 'Hibrit'];
    final List<String> internshipTypes = ['Tümü', 'Zorunlu', 'Gönüllü', 'Uzun Dönem'];
    final List<String> locations = [
      'Tümü',
      ..._allPosts.map((p) => p.location).toSet().toList()..sort()
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detaylı Filtreleme',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedCategory = 'Tümü';
                              _selectedWorkType = 'Tümü';
                              _selectedInternshipType = 'Tümü';
                              _selectedLocation = 'Tümü';
                            });
                            setState(() {
                              _selectedCategory = 'Tümü';
                              _selectedWorkType = 'Tümü';
                              _selectedInternshipType = 'Tümü';
                              _selectedLocation = 'Tümü';
                            });
                          },
                          child: const Text('Temizle',
                              style: TextStyle(color: Colors.red)),
                        )
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Kategori
                    const Text('Kategori',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          showCheckmark: false,
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: Colors.blueAccent,
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87),
                          onSelected: (selected) {
                            setModalState(() => _selectedCategory = cat);
                            setState(() => _selectedCategory = cat);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Çalışma Şekli
                    const Text('Çalışma Şekli',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: workTypes.map((wt) {
                        final isSelected = _selectedWorkType == wt;
                        return ChoiceChip(
                          showCheckmark: false,
                          label: Text(wt),
                          selected: isSelected,
                          selectedColor: Colors.blueAccent,
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87),
                          onSelected: (selected) {
                            setModalState(() => _selectedWorkType = wt);
                            setState(() => _selectedWorkType = wt);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Staj Türü
                    const Text('Staj Türü',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: internshipTypes.map((it) {
                        final isSelected = _selectedInternshipType == it;
                        return ChoiceChip(
                          showCheckmark: false,
                          label: Text(it),
                          selected: isSelected,
                          selectedColor: Colors.blueAccent,
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87),
                          onSelected: (selected) {
                            setModalState(() => _selectedInternshipType = it);
                            setState(() => _selectedInternshipType = it);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Konum
                    const Text('Konum',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedLocation),
                      value: _selectedLocation,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: locations.map((loc) {
                        return DropdownMenuItem<String>(
                          value: loc,
                          child: Text(loc),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => _selectedLocation = val);
                          setState(() => _selectedLocation = val);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Uygula Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E3A59),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Uygula',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryRow() {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Tümü', 'icon': Icons.all_inclusive},
      {'name': 'Yazılım', 'icon': Icons.code},
      {'name': 'Tasarım', 'icon': Icons.palette},
      {'name': 'Veri Bilimi', 'icon': Icons.analytics},
      {'name': 'Pazarlama', 'icon': Icons.trending_up},
      {'name': 'Mühendislik', 'icon': Icons.build},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final String name = cat['name'];
          final IconData icon = cat['icon'];
          final isSelected = _selectedCategory == name;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              showCheckmark: false,
              avatar: Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              label: Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.blueAccent,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                ),
              ),
              onSelected: (bool selected) {
                setState(() {
                  _selectedCategory = selected ? name : 'Tümü';
                });
              },
            ),
          );
        },
      ),
    );
  }

  bool _matchesCategory(PostModel model, String category) {
    if (category == 'Tümü') return true;

    List<String> keywords;
    switch (category) {
      case 'Yazılım':
        keywords = CategoryKeywords.software;
        break;
      case 'Veri Bilimi':
        keywords = CategoryKeywords.dataScience;
        break;
      case 'Tasarım':
        keywords = CategoryKeywords.design;
        break;
      case 'Pazarlama':
        keywords = CategoryKeywords.marketing;
        break;
      case 'Mühendislik':
        keywords = CategoryKeywords.engineering;
        break;
      default:
        return false;
    }

    final title = model.positionTitle.toLowerCase();
    final tags = model.tags.map((t) => t.toLowerCase()).toList();

    for (var keyword in keywords) {
      final kw = keyword.toLowerCase();
      
      if (kw.length <= 3) {
        final regex = RegExp('\\b${RegExp.escape(kw)}\\b');
        if (regex.hasMatch(title) || tags.any((tag) => regex.hasMatch(tag))) {
          if (category == 'Mühendislik' && _isSoftwareEngineering(title, tags)) {
            continue;
          }
          return true;
        }
      } else {
        if (title.contains(kw) || tags.any((tag) => tag.contains(kw))) {
          if (category == 'Mühendislik' && _isSoftwareEngineering(title, tags)) {
            continue;
          }
          return true;
        }
      }
    }

    return false;
  }

  bool _isSoftwareEngineering(String title, List<String> tags) {
    final softKeywords = CategoryKeywords.software;
    for (var keyword in softKeywords) {
      final kw = keyword.toLowerCase();
      if (title.contains(kw) || tags.any((tag) => tag.contains(kw))) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasActiveFilters = _selectedCategory != 'Tümü' ||
        _selectedWorkType != 'Tümü' ||
        _selectedInternshipType != 'Tümü' ||
        _selectedLocation != 'Tümü';

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
                const SizedBox(height: 20),
                if (_completionRate < 1.0)
                  buildProfileCompletionCard(
                      context, _completionRate, widget.onGoToProfile),
                const SizedBox(height: 20),
                buildSearchBar(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onFilterTap: _showFilterBottomSheet,
                  hasActiveFilters: hasActiveFilters,
                ),
                const SizedBox(height: 16),
                _buildCategoryRow(),
                const SizedBox(height: 24),
                const Text(
                  'En Yeni İlanlar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<PostModel>>(
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
                      _allPosts = posts;

                      var filteredList = posts;

                      if (_selectedCategory != 'Tümü') {
                        filteredList = filteredList.where((model) {
                          return _matchesCategory(model, _selectedCategory);
                        }).toList();
                      }

                      if (_selectedWorkType != 'Tümü') {
                        filteredList = filteredList.where((model) {
                          return model.workType.toLowerCase() == _selectedWorkType.toLowerCase();
                        }).toList();
                      }

                      if (_selectedInternshipType != 'Tümü') {
                        filteredList = filteredList.where((model) {
                          return model.internshipType.toLowerCase() == _selectedInternshipType.toLowerCase();
                        }).toList();
                      }

                      if (_selectedLocation != 'Tümü') {
                        filteredList = filteredList.where((model) {
                          return model.location.toLowerCase() == _selectedLocation.toLowerCase();
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
                const SizedBox(height: 24),
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
