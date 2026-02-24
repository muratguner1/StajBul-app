import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';
import 'package:staj_bul_demo/models/student_profile_model.dart';
import 'package:staj_bul_demo/models/user_model.dart';

class CommonRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    LogService.info('Getting current user');
    return _auth.currentUser;
  }

  Future<DocumentSnapshot?> getStudentProfile(String userId) async {
    LogService.info('Getting student profile for $userId.');
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc;
      }
      return null;
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when getting student profile!', e, stackTrace);
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
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when getting student profile!', e, stackTrace);
      rethrow;
    }
  }

  Future<UserModel?> getUserModel(String userId) async {
    LogService.info('Getting user informations for $userId');
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return null;
    } catch (e, stcakTrace) {
      LogService.error(
          'An error occured when getting user informations', e, stcakTrace);
      rethrow;
    }
  }

  Future<void> updateStudentProfile(StudentProfileModel model) async {
    LogService.info("Updating ${model.fullName}'s profile ");
    try {
      await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(model.uid)
          .update(model.toJson());
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when updating student profile!', e, stackTrace);
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

  //şuanda kullanılmıyor
  Stream<DocumentSnapshot> getStudentProfileStream(String userId) {
    return _firestore
        .collection(FirestoreCollections.studentProfiles)
        .doc(userId)
        .snapshots();
  }
}
