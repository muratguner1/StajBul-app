import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String listingId;
  final String companyId;
  final String positionTitle;
  final String description;
  final String qualifications;
  final String location;
  final String locationType;
  final String internshipType;
  //final List<String> tags;
  final Timestamp createdAt;
  final bool isActive;

  final String companyName;
  final String? companyLogoUrl;

  ListingModel({
    required this.listingId,
    required this.companyId,
    required this.positionTitle,
    required this.description,
    required this.qualifications,
    required this.location,
    required this.locationType,
    required this.internshipType,
    //required this.tags,
    required this.createdAt,
    required this.isActive,
    required this.companyName,
    this.companyLogoUrl,
  });

  factory ListingModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return ListingModel(
      listingId: snap.id,
      companyId: data['companyId'] ?? '',
      positionTitle: data['positionTitle'] ?? '',
      description: data['description'] ?? '',
      qualifications: data['qualifications'] ?? '',
      location: data['location'] ?? '',
      locationType: data['locationType'] ?? '',
      internshipType: data['internshipType'] ?? '',
      //tags: List<String>.from(data['tags'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isActive: data['isActive'] ?? true,
      companyName: data['companyName'] ?? '',
      companyLogoUrl: data['companyLogoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'positionTitle': positionTitle,
      'description': description,
      'qualifications': qualifications,
      'location': location,
      'locationType': locationType,
      'internshipType': internshipType,
      //'tags': tags,
      'createdAt': createdAt,
      'isActive': isActive,
      'companyName': companyName,
      'companyLogoUrl': companyLogoUrl,
    };
  }
}
