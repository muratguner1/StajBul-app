import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';
import 'package:staj_bul_demo/models/student_profile_model.dart';
import 'package:staj_bul_demo/repositories/student/common_repository.dart';

class StudentProfileRepository {
  final CommonRepository _commonRepository = CommonRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sadece profil fotoğrafı URL'sini getirir
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      final doc = await _commonRepository.getStudentProfile(userId);
      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data[FirestoreStudentFields.profileImageUrl];
      }
      return null;
    } catch (e) {
      print('Profil fotoğrafı URL çekme hatası: $e');
      return null;
    }
  }

  // Profil fotoğrafını Firebase Storage'a yükler ve URL'ini Firestore'a kaydeder
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Storage'a yükle
      final ref = _storage.ref().child('student_images').child('$userId.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      // Firestore'a URL'i kaydet
      await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(userId)
          .update({FirestoreStudentFields.profileImageUrl: downloadUrl});

      return downloadUrl;
    } catch (e) {
      print('Profil fotoğrafı yükleme hatası: $e');
      rethrow;
    }
  }

  // Profil fotoğrafını siler (sadece Firestore'dan, Storage'dan silmez)
  Future<void> deleteProfileImage(String userId) async {
    try {
      await _firestore
          .collection(FirestoreCollections.studentProfiles)
          .doc(userId)
          .update({
        FirestoreStudentFields.profileImageUrl: FieldValue.delete(),
      });
    } catch (e) {
      print('Profil fotoğrafı silme hatası: $e');
      rethrow;
    }
  }

  // Varsayılan profil fotoğrafı URL'sini getirir
  Future<String?> getDefaultPhotoUrl() async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.defaultProfile)
          .doc('1')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['default_photo_url'];
      }
      return null;
    } catch (e) {
      print('Varsayılan fotoğraf URL çekme hatası: $e');
      return null;
    }
  }

  //Experiences Tab
  //İç koleksiyon erişimi
  CollectionReference<Map<String, dynamic>> getInnerCollection(
      String userId, String collection) {
    return _firestore
        .collection(FirestoreCollections.studentProfiles)
        .doc(userId)
        .collection(collection);
  }

  // Deneyim silme
  Future<void> deleteExperience(String userId, String docId) async {
    await _firestore
        .collection(FirestoreCollections.studentProfiles)
        .doc(userId)
        .collection('experiences')
        .doc(docId)
        .delete();
  }

  Stream<QuerySnapshot<Object?>> getAllExperiences(String userId) {
    return _firestore
        .collection(FirestoreCollections.studentProfiles)
        .doc(userId)
        .collection(FirestoreCollections.experiences)
        .orderBy('startDate', descending: true)
        .snapshots();
  }

  //Resume Tab
  Future<void> uploadResume(
      String userId, String fileName, File file, String resumeName) async {
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
  }

  Future<void> deleteResume(
      Map<String, dynamic> resumeItem, String userId) async {
    if (resumeItem['storagePath'] != null) {
      await _storage.ref(resumeItem['storagePath']).delete();
    }

    await _firestore
        .collection(FirestoreCollections.studentProfiles)
        .doc(userId)
        .update({
      'resumes': FieldValue.arrayRemove([resumeItem])
    });
  }

  //Skills & Languages Tab

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
