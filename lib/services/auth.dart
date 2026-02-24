import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';
import 'package:staj_bul_demo/models/user_model.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';
import 'package:staj_bul_demo/core/constants/user_roles.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
    await for (final firebaseUser in _auth.authStateChanges()) {
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
      final result = await _auth.createUserWithEmailAndPassword(
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
        await _firestore
            .collection(FirestoreCollections.studentProfiles)
            .doc(user.uid)
            .set({
          FirestoreStudentFields.fullName: name,
          'createdAt': Timestamp.now(),
        });
      } else if (role == UserRoles.company) {
        await _firestore
            .collection(FirestoreCollections.companyProfiles)
            .doc(user.uid)
            .set({
          FirestoreStudentFields.fullName: name,
          'createdAt': Timestamp.now(),
        });
      } //sonra admin için de ekleme yap

      return userModel;
    } catch (e, stackTrace) {
      LogService.error('An error occured when user register!', e, stackTrace);
      rethrow;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return await _userFromFirebase(result.user);
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when user reset password!', e, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
