import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';

class ResumeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> uploadResume(
      String userId, String fileName, File file, String resumeName) async {
    LogService.info('Uploading resume');
    try {
      final ref = _storage.ref().child('resumes').child(userId).child(fileName);

      await ref.putFile(file);
      final String downloadUrl = await ref.getDownloadURL();

      final newResume = {
        'name': resumeName,
        'url': downloadUrl,
        'storagePath': ref.fullPath,
        'uploadedAt': Timestamp.now(),
      };

      await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(userId)
          .update({
        'resumes': FieldValue.arrayUnion([newResume])
      });
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when uploading resume!', e, stackTrace);
    }
  }

  Future<void> deleteResume(
      Map<String, dynamic> resumeItem, String userId) async {
    LogService.info('Deleting resume');
    try {
      if (resumeItem['storagePath'] != null) {
        await _storage.ref(resumeItem['storagePath']).delete();
      }

      await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(userId)
          .update({
        'resumes': FieldValue.arrayRemove([resumeItem])
      });
    } catch (e, stackTrace) {
      LogService.error('An error occured when deleting resume', e, stackTrace);
    }
  }
}
