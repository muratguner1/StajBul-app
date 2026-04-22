import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/common.dart';
import 'package:staj_bul_demo/models/application_model.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';

class ApplicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> applyToPost(ApplicationModel model) async {
    LogService.info('Applying to post ${model.postId}');
    try {
      await _firestore
          .collection(FirestoreCollections.applications)
          .doc(model.applicationId)
          .set(model.toJson());
    } catch (e, stackTrace) {
      LogService.error('An error occured when applying post!', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> hasStudentApplied(String postId, String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.applications)
          .where(FireStorePostFields.postId, isEqualTo: postId)
          .where(FirestoreStudentFields.studentId, isEqualTo: studentId)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Stream<List<ApplicationModel>> getStudentApplicationsStream(
      String studentId) {
    return _firestore
        .collection(FirestoreCollections.applications)
        .where(FirestoreStudentFields.studentId, isEqualTo: studentId)
        .orderBy(FireStoreApplicationFields.appliedAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromSnapshot(doc))
            .toList());
  }

  Stream<List<ApplicationModel>> getCompanyApplicationsStream(
      String companyId) {
    return _firestore
        .collection(FirestoreCollections.applications)
        .where(FirestoreCompanyFields.companyId, isEqualTo: companyId)
        .orderBy(FireStoreApplicationFields.appliedAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromSnapshot(doc))
            .toList());
  }

  Future<void> updateApplicationStatus(
      String applicationId, String newStatus) async {
    LogService.info('Updating application status.');
    try {
      await _firestore
          .collection(FirestoreCollections.applications)
          .doc(applicationId)
          .update({
        FireStoreApplicationFields.status: newStatus,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getApplicationStatusForPost(
      String postId, String studentId) async {
    LogService.info('getting application status for post $postId.');
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.applications)
          .where(FireStorePostFields.postId, isEqualTo: postId)
          .where(FirestoreStudentFields.studentId, isEqualTo: studentId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data()['status'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<List<ApplicationModel>> getPostApplicationsStream(String postId) {
    return _firestore
        .collection(FirestoreCollections.applications)
        .where(FireStorePostFields.postId, isEqualTo: postId)
        .orderBy(FireStoreApplicationFields.appliedAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromSnapshot(doc))
            .toList());
  }
}
