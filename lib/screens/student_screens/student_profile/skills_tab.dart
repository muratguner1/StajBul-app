import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';
import 'package:staj_bul_demo/repositories/student/profile/skills_repository.dart';
import 'package:staj_bul_demo/widgets/custom_widgets/awesome_snack_bar.dart';

class SkillsTab extends StatefulWidget {
  const SkillsTab({super.key});

  @override
  State<SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends State<SkillsTab> {
  final SkillsRepository _skillsRepository = SkillsRepository();
  final CommonRepository _commonRepository = CommonRepository();

  List<String> _skills = [];
  List<String> _languages = [];

  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final user = _commonRepository.getCurrentUser();
    if (user != null) {
      try {
        final doc = await _commonRepository.getStudentProfile(user.uid);
        Map<String, dynamic>? data = doc?.data() as Map<String, dynamic>?;

        if (data != null) {
          setState(() {
            _skills = List<String>.from(data['skills'] ?? []);
            _languages = List<String>.from(data['languages'] ?? []);
          });
        }
      } catch (e) {
        print("Hata: $e");
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    final user = _commonRepository.getCurrentUser();
    if (user != null) {
      try {
        await _skillsRepository.updateSkillsAndLanguages(
            user.uid, _skills, _languages);

        setState(() => _isEditing = false);

        if (mounted) {
          AwesomeSnackBar.show(context,
              title: '',
              message: 'Yetenekler ve Diller güncellendi!',
              contentType: ContentType.success);
        }
      } catch (e) {
        if (mounted) {
          AwesomeSnackBar.show(context,
              title: '',
              message: 'Bir hata oluştu.',
              contentType: ContentType.failure);
        }
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _addItem(List<String> list, TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isNotEmpty && !list.contains(text)) {
      setState(() {
        list.add(text);
        controller.clear();
      });
    }
  }

  void _removeItem(List<String> list, String item) {
    setState(() {
      list.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _skills.isEmpty && _languages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Yetenek & Dil",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _isEditing
                  ? Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() => _isEditing = false);
                              _fetchData();
                            },
                            child: const Text("İptal",
                                style: TextStyle(color: Colors.grey))),
                        ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white),
                            child: const Text("Kaydet")),
                      ],
                    )
                  : TextButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.blueAccent,
                      ),
                      label: const Text(
                        "Düzenle",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          const Text("Yetenekler",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
          const SizedBox(height: 10),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillController,
                      decoration: const InputDecoration(
                        hintText: "Yetenek yaz (Örn: Flutter)",
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onSubmitted: (_) => _addItem(_skills, _skillController),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon:
                        const Icon(Icons.add_circle, color: Colors.blueAccent),
                    onPressed: () => _addItem(_skills, _skillController),
                  )
                ],
              ),
            ),
          _buildChipList(_skills, _isEditing),
          const SizedBox(height: 24),
          const Text("Yabancı Diller",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
          const SizedBox(height: 10),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _languageController,
                      decoration: const InputDecoration(
                        hintText: "Dil yaz (Örn: İngilizce - Orta)",
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onSubmitted: (_) =>
                          _addItem(_languages, _languageController),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () => _addItem(_languages, _languageController),
                  )
                ],
              ),
            ),
          _buildChipList(_languages, _isEditing,
              color: Colors.green.shade100, textColor: Colors.green.shade900),
        ],
      ),
    );
  }

  Widget _buildChipList(List<String> items, bool isEditing,
      {Color? color, Color? textColor}) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child:
            Text("- Henüz eklenmemiş -", style: TextStyle(color: Colors.grey)),
      );
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: items.map((item) {
        return Chip(
          label: Text(item,
              style: TextStyle(color: textColor ?? Colors.blue.shade900)),
          backgroundColor: color ?? Colors.blue.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          deleteIcon: isEditing
              ? const Icon(Icons.close, size: 18, color: Colors.redAccent)
              : null,
          onDeleted: isEditing ? () => _removeItem(items, item) : null,
        );
      }).toList(),
    );
  }
}
