import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';
import 'package:staj_bul_demo/models/student_profile_model.dart';

class CommonRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<DocumentSnapshot?> getStudentProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc;
      }
      return null;
    } catch (e) {
      print('Profil çekme hatası: $e');
      rethrow;
    }
  }

  Future<StudentProfileModel?> getStudentProfileModel(String userId) async {
    try {
      final doc = await getStudentProfile(userId);
      if (doc != null && doc.exists) {
        return StudentProfileModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      print('Profil model çekme hatası: $e');
      return null;
    }
  }

  Future<void> updateStudentProfile(StudentProfileModel model) async {
    try {
      await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(model.uid)
          .update(model.toJson());
    } catch (e) {
      print('Hata: e');
      rethrow;
    }
  }

  CollectionReference<Map<String, dynamic>> getInnerCollection(
      String userId, String collection) {
    return _firestore
        .collection(FirestoreCollections.studentProfiles)
        .doc(userId)
        .collection(collection);
  }

  Stream<DocumentSnapshot> getStudentProfileStream(String userId) {
    return _firestore
        .collection(FirestoreCollections.studentProfiles)
        .doc(userId)
        .snapshots();
  }
}
