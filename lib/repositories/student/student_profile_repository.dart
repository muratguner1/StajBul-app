import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:staj_bul_demo/core/constants/common.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';
import 'package:staj_bul_demo/models/experience_model.dart';
import 'package:staj_bul_demo/models/student_profile_model.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';

class StudentProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CommonRepository _commonRepository = CommonRepository();

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

  Stream<StudentProfileModel?> getStudentProfileStream(String uid) {
    return _firestore
        .collection(FirestoreCollections.studentProfiles)
        .doc(uid)
        .snapshots()
        .map((snap) {
      if (snap.exists) {
        return StudentProfileModel.fromSnapshot(snap);
      }
      return null;
    });
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

  Future<String?> getProfileImageUrl(String userId) async {
    LogService.info('Getting profile image of: $userId');
    try {
      final doc = await getStudentProfile(userId);
      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data[FirestoreStudentFields.profileImageUrl];
      }
      return null;
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when getting profile image', e, stackTrace);
      rethrow;
    }
  }

  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      LogService.info('Uploading student profile image to the storage');
      final ref = _storage.ref().child('student_images').child('$userId.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      LogService.info('Saving student profile image url to the firestore');
      await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(userId)
          .update({FirestoreStudentFields.profileImageUrl: downloadUrl});

      return downloadUrl;
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when uploading profile image', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteProfileImage(String userId) async {
    LogService.info('Deleting profile image.');
    try {
      await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(userId)
          .update({
        FirestoreStudentFields.profileImageUrl: FieldValue.delete(),
      });
      LogService.info('Deleting profile image.');
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when deleting profile image', e, stackTrace);
      rethrow;
    }
  }

  Future<String?> getDefaultPhotoUrl() async {
    LogService.info('Getting default profile photo');

    try {
      final doc = await _firestore
          .collection(FirestoreCollections.defaultProfile)
          .doc('1')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;

        final defaultp = data['default_photo_url'];

        return defaultp;
      }

      return null;
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when getting default profile image', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateContactInfo({
    required String uid,
    String? phone,
    String? linkedin,
    String? github,
    String? address,
    String? portfolio,
  }) async {
    LogService.info('updating user contact informations for user: $uid');
    try {
      await _firestore.collection(FirestoreCollections.users).doc(uid).update({
        FirestoreUserFields.phone: phone,
        FirestoreUserFields.linkedin: linkedin,
        FirestoreUserFields.github: github,
        FirestoreUserFields.address: address,
        FirestoreUserFields.portfolio: portfolio,
      });
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when getting user contact informations!',
          e,
          stackTrace);
    }
  }

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

  Future<void> uploadResume(
      String userId, String fileName, File file, String resumeName) async {
    LogService.info('Uploading resume');
    try {
      final ref = _storage.ref().child('resumes').child(userId).child(fileName);

      await ref.putFile(file);
      final String downloadUrl = await ref.getDownloadURL();

      final resumeData = {
        'name': resumeName,
        'url': downloadUrl,
        'storagePath': ref.fullPath,
        'uploadedAt': Timestamp.now(),
      };

      await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(userId)
          .update({
        FirestoreStudentFields.cvUrl: downloadUrl,
        'resumeData': resumeData
      });
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when uploading resume!', e, stackTrace);
    }
  }

  Future<void> deleteResume(String storagePath, String userId) async {
    LogService.info('Deleting resume');
    try {
      if (storagePath.isNotEmpty) {
        await _storage.ref(storagePath).delete();
      }

      await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(userId)
          .update({
        FirestoreStudentFields.cvUrl: FieldValue.delete(),
        'resumeData': FieldValue.delete()
      });
    } catch (e, stackTrace) {
      LogService.error('An error occured when deleting resume', e, stackTrace);
    }
  }

  Future<void> updateSkillsAndLanguages(
      String userId, List<String> skills, List<String> languages) async {
    LogService.info('Updating skills');
    try {
      await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(userId)
          .update({
        'skills': skills,
        'languages': languages,
      });
    } catch (e, stackTrace) {
      LogService.error('An error occured when updating skills!', e, stackTrace);
      rethrow;
    }
  }
}
