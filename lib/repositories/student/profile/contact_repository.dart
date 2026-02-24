import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';

class ContactRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}
