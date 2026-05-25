import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/common.dart';

class CompanyProfileModel {
  final String uid;
  final String companyName;
  final String? logoUrl;
  final String? location;
  final String? website;
  final String? industry;
  final String? aboutCompany;

  CompanyProfileModel({
    required this.uid,
    required this.companyName,
    this.logoUrl,
    this.location,
    this.website,
    this.industry,
    this.aboutCompany,
  });

  CompanyProfileModel copyWith({
    final String? uid,
    final String? companyName,
    final String? logoUrl,
    final String? location,
    final String? website,
    final String? industry,
    final String? aboutCompany,
  }) {
    return CompanyProfileModel(
      uid: uid ?? this.uid,
      companyName: companyName ?? this.companyName,
      logoUrl: logoUrl ?? this.logoUrl,
      location: location ?? this.location,
      website: website ?? this.website,
      industry: industry ?? this.industry,
      aboutCompany: aboutCompany ?? this.aboutCompany,
    );
  }

  factory CompanyProfileModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return CompanyProfileModel(
      uid: snap.id,
      companyName: data[FirestoreCompanyFields.companyName] ?? '',
      logoUrl: data[FirestoreCompanyFields.logoUrl],
      location: data[FirestoreCompanyFields.location] ?? '',
      website: data[FirestoreCompanyFields.website] ?? '',
      industry: data[FirestoreCompanyFields.industry] ?? '',
      aboutCompany: data[FirestoreCompanyFields.aboutCompany],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirestoreCompanyFields.companyName: companyName,
      FirestoreCompanyFields.logoUrl: logoUrl,
      FirestoreCompanyFields.location: location,
      FirestoreCompanyFields.website: website,
      FirestoreCompanyFields.industry: industry,
      FirestoreCompanyFields.aboutCompany: aboutCompany,
    };
  }
}
