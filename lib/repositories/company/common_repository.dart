import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staj_bul_demo/core/constants/common.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';
import 'package:staj_bul_demo/models/user_model.dart';

class CommonRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    LogService.info('Getting current user');
    return _auth.currentUser;
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
}
