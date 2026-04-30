import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/common.dart';
import 'package:staj_bul_demo/core/services/log_service.dart';
import 'package:staj_bul_demo/models/company_profile_model.dart';

class CompanyProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> getCompanyProfile(String companyId) async {
    LogService.info('Getting company profile for $companyId');

    try {
      final doc = await _firestore
          .collection(FirestoreCollections.companyProfiles)
          .doc(companyId)
          .get();

      if (doc.exists) {
        return doc;
      }

      return null;
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when getting company profile!', e, stackTrace);
      rethrow;
    }
  }

  Future<CompanyProfileModel?> getCompanyProfileModel(String companyId) async {
    try {
      final doc = await getCompanyProfile(companyId);

      if (doc != null && doc.exists) {
        return CompanyProfileModel.fromSnapshot(doc);
      }
      return null;
    } catch (e, stackTrace) {
      LogService.error('An error occured when getting company profile model!',
          e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateCompanyProfile(CompanyProfileModel model) async {
    LogService.info('Updating company profile for: ${model.companyName}');

    try {
      await _firestore
          .collection(FirestoreCollections.companyProfiles)
          .doc(model.uid)
          .update(model.toJson());
    } catch (e, stackTrace) {
      LogService.error(
          'An error occured when updating company profile!', e, stackTrace);
      rethrow;
    }
  }
}
