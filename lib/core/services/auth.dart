import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';
import 'package:staj_bul_demo/models/company_profile_model.dart';
import 'package:staj_bul_demo/models/student_profile_model.dart';
import 'package:staj_bul_demo/models/user_model.dart';
import 'package:staj_bul_demo/core/constants/common.dart';
import 'package:staj_bul_demo/core/constants/user_roles.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> _userFromFirebase(User? user) async {
    if (user == null) return null;

    final doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    return UserModel.fromSnapshot(doc);
  }

  Stream<UserModel?> get user async* {
    await for (final firebaseUser in _firebaseAuth.authStateChanges()) {
      if (firebaseUser == null) {
        yield null;
      } else {
        yield await _userFromFirebase(firebaseUser);
      }
    }
  }

  Future<UserModel?> register(
      String email, String password, String role, String name) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        return null;
      }

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        role: role,
        createdAt: Timestamp.now(),
      );

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set(userModel.toJson());

      if (role == UserRoles.student) {
        final studentModel = StudentProfileModel(
          uid: userModel.uid,
          fullName: name,
          email: email,
          university: null,
          department: null,
          studentClass: null,
          startYear: null,
          graduationYear: null,
          profileImageUrl: null,
          aboutMe: null,
          skills: null,
          cvUrl: null,
          isProfileComplete: null,
          savedPostIds: null,
        );

        await _firestore
            .collection(FirestoreCollections.studentProfiles)
            .doc(user.uid)
            .set(studentModel.toJson());
      } else if (role == UserRoles.company) {
        final CompanyProfileModel model =
            CompanyProfileModel(uid: user.uid, companyName: name);
        await _firestore
            .collection(FirestoreCollections.companyProfiles)
            .doc(user.uid)
            .set(model.toJson());
      } //sonra admin için de ekleme yap

      return userModel;
    } catch (e, stackTrace) {
      LogService.error('An error occured when user register!', e, stackTrace);
      rethrow;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    final result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return await _userFromFirebase(result.user);
  }

  Future<void> resetPassword(String email) async {
    LogService.info('Reseting password for email: $email');
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when user reset password!', e, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    LogService.info('Logging out');
    await _firebaseAuth.signOut();
  }

  Future<void> deleteAccount(String userId, String roleCollection) async {
    LogService.info('Deleting account for user: $userId');
    try {
      await _firebaseAuth.currentUser?.delete();
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .delete();
      await _firestore.collection(roleCollection).doc(userId).delete();
      await _firebaseAuth.signOut();
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when deleting  account!', e, stackTrace);
      rethrow;
    }
  }
}
