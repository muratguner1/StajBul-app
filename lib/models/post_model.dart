import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/common.dart';

class PostModel {
  final String postId;
  final String companyId;
  final String positionTitle;
  final String description;
  final String qualifications;
  final String location;
  final String workType;
  final String internshipType;
  final List<String> tags;
  final Timestamp createdAt;
  final bool isActive;

  final String companyName;
  final String? logoUrl;

  PostModel({
    required this.postId,
    required this.companyId,
    required this.positionTitle,
    required this.description,
    required this.qualifications,
    required this.location,
    required this.workType,
    required this.internshipType,
    required this.tags,
    required this.createdAt,
    required this.isActive,
    required this.companyName,
    this.logoUrl,
  });

  factory PostModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return PostModel(
      postId: snap.id,
      companyId: data[FirestoreCompanyFields.companyId] ?? '',
      positionTitle: data[FireStorePostFields.positionTitle] ?? '',
      description: data[FireStorePostFields.description] ?? '',
      qualifications: data[FireStorePostFields.qualifications] ?? '',
      location: data[FirestoreCompanyFields.location] ?? '',
      workType: data[FireStorePostFields.workType] ?? '',
      internshipType: data[FireStorePostFields.internshipType] ?? '',
      tags: List<String>.from(data[FireStorePostFields.tags] ?? []),
      createdAt: data[FireStorePostFields.createdAt] ?? Timestamp.now(),
      isActive: data[FireStorePostFields.isActive] ?? true,
      companyName: data[FirestoreCompanyFields.companyName] ?? '',
      logoUrl: data[FirestoreCompanyFields.logoUrl],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirestoreCompanyFields.companyId: companyId,
      FireStorePostFields.positionTitle: positionTitle,
      FireStorePostFields.description: description,
      FireStorePostFields.qualifications: qualifications,
      FirestoreCompanyFields.location: location,
      FireStorePostFields.workType: workType,
      FireStorePostFields.internshipType: internshipType,
      FireStorePostFields.tags: tags,
      FireStorePostFields.createdAt: createdAt,
      FireStorePostFields.isActive: isActive,
      FirestoreCompanyFields.companyName: companyName,
      FirestoreCompanyFields.logoUrl: logoUrl,
    };
  }

  PostModel copyWith({
    String? jobPostId,
    String? companyId,
    String? positionTitle,
    String? description,
    String? qualifications,
    String? location,
    String? workType,
    String? internshipType,
    List<String>? tags,
    Timestamp? createdAt,
    bool? isActive,
    String? companyName,
    String? logoUrl,
  }) {
    return PostModel(
      postId: jobPostId ?? this.postId,
      companyId: companyId ?? this.companyId,
      positionTitle: positionTitle ?? this.positionTitle,
      description: description ?? this.description,
      qualifications: qualifications ?? this.qualifications,
      location: location ?? this.location,
      workType: workType ?? this.workType,
      internshipType: internshipType ?? this.internshipType,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      companyName: companyName ?? this.companyName,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
