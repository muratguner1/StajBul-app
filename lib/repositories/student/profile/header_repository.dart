import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';

class HeaderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CommonRepository _commonRepository = CommonRepository();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> getProfileImageUrl(String userId) async {
    LogService.info('Getting profile image of: $userId');
    try {
      final doc = await _commonRepository.getStudentProfile(userId);
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
}
