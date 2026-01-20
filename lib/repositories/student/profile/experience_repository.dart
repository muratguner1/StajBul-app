import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';
import 'package:staj_bul_demo/models/experience_model.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';

class ExperienceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CommonRepository _commonRepository = CommonRepository();

  Future<void> deleteExperience(String userId, String docId) async {
    LogService.info('Deleting experience: $docId');
    try {
      await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(userId)
          .collection(FirestoreCollections.experiences)
          .doc(docId)
          .delete();
      LogService.debug('Deleting successful');
    } catch (e, stackTrace) {
      LogService.error('The experience could not be deleted!', e, stackTrace);
      rethrow;
    }
    LogService.info('$docId experience deleted!');
  }

  Stream<List<ExperienceModel>> getAllExperiences(String userId) {
    LogService.debug('Getting all experiences: $userId');
    return _firestore
        .collection(FirestoreCollections.studentProfiles)
        .doc(userId)
        .collection(FirestoreCollections.experiences)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ExperienceModel.fromSnapshot(doc))
          .toList();
    });
  }

  Future<void> saveExperience(String userId, ExperienceModel experience) async {
    LogService.info('Saving experience ${experience.id}');
    try {
      final collectionRef = _commonRepository.getInnerCollection(
          userId, FirestoreCollections.experiences);
      if (experience.id.isEmpty) {
        await collectionRef.add(experience.toJson());
        LogService.info('Experience appended successfuly.');
      } else {
        await collectionRef.doc(experience.id).update(experience.toJson());
        LogService.info('Experience updated successfuly.');
      }
    } catch (e, stackTrace) {
      LogService.error('An error occur when saving experience!', e, stackTrace);
      rethrow;
    }
  }
}
