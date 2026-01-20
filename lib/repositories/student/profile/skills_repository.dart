import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';

class SkillsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateSkillsAndLanguages(
      String userId, List<String> skills, List<String> languages) async {
    try {
      await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(userId)
          .update({
        'skills': skills,
        'languages': languages,
      });
    } catch (e) {
      print("Güncelleme hatası: $e");
      rethrow;
    }
  }
}
