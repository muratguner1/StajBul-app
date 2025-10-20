import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyProfileModel {
  final String uid;
  final String companyName;
  final String? logoUrl;
  final String location;
  final String? website;
  final String industry;
  final String? aboutCompany;

  CompanyProfileModel({
    required this.uid,
    required this.companyName,
    this.logoUrl,
    required this.location,
    this.website,
    required this.industry,
    this.aboutCompany,
  });

  factory CompanyProfileModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return CompanyProfileModel(
      uid: snap.id,
      companyName: data['companyName'] ?? '',
      logoUrl: data['logoUrl'],
      location: data['location'] ?? '',
      website: data['website'],
      industry: data['industry'] ?? '',
      aboutCompany: data['aboutCompany'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'logoUrl': logoUrl,
      'location': location,
      'website': website,
      'industry': industry,
      'aboutCompany': aboutCompany,
    };
  }
}
