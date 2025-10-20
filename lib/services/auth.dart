import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staj_bul_demo/models/user_model.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> _userFromFirebase(User? user) async {
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

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
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());

      if (role == 'student') {
        await _firestore.collection('studentProfiles').doc(user.uid).set({
          'fullName': name,
          'createdAt': Timestamp.now(),
        });
      } else {
        await _firestore.collection('companyProfiles').doc(user.uid).set({
          'fullName': name,
          'createdAt': Timestamp.now(),
        });
      }

      return userModel;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return await _userFromFirebase(result.user);
  }

  Future<void> resedPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Resed password error: $e');
      rethrow;
    }
  }

  /*Future<bool> isEmailRegistered(String email) async {
    try {
      final isExist = await _auth.
    } catch (e) {}
  } */

  Future<void> logout() async {
    await _auth.signOut();
  }
}
