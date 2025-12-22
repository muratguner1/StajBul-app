import 'package:flutter/material.dart';
import 'package:staj_bul_demo/widgets/student/home_page/build_header.dart';
import 'package:staj_bul_demo/widgets/student/home_page/build_profile_completition_card.dart';
import 'package:staj_bul_demo/widgets/student/home_page/build_recent_internships.dart';
import 'package:staj_bul_demo/widgets/student/home_page/build_search_bar.dart';
import 'package:staj_bul_demo/widgets/student/home_page/build_categories.dart';
import 'package:staj_bul_demo/widgets/student/home_page/build_section_title.dart';

class StudentHomePage extends StatefulWidget {
  final VoidCallback onGoToProfile;
  const StudentHomePage({super.key, required this.onGoToProfile});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  // bunu sonra firestora ekleyip ordan çek
  final double _completionRate = 0.4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader('murat'),
              SizedBox(height: 20),
              if (_completionRate < 1.0)
                buildProfileCompletionCard(
                    context, _completionRate, widget.onGoToProfile),
              SizedBox(height: 20),
              buildSearchBar(),
              SizedBox(height: 24),
              buildSectionTitle("Kategoriler"),
              SizedBox(height: 12),
              buildCategories(context),
              SizedBox(height: 24),
              buildRecentInternships(context, 5),
            ],
          ),
        ),
      ),
    );
  }
}
