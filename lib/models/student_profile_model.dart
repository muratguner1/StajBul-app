import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';

class StudentProfileModel {
  final String uid;
  final String fullName;
  final String university;
  final String department;
  final int startYear;
  final int? graduationYear;
  final String? profileImageUrl;
  final String? aboutMe;
  final List<String> skills;
  final String? cvUrl;
  final bool isProfileComplete;
  final List<String> savedListingIds;

  StudentProfileModel({
    required this.uid,
    required this.fullName,
    required this.university,
    required this.department,
    required this.startYear,
    this.graduationYear,
    this.profileImageUrl,
    this.aboutMe,
    required this.skills,
    this.cvUrl,
    required this.isProfileComplete,
    required this.savedListingIds,
  });

  factory StudentProfileModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return StudentProfileModel(
      uid: snap.id,
      fullName: data[FirestoreFields.fullName] ?? '',
      university: data[FirestoreFields.university] ?? '',
      department: data[FirestoreFields.department] ?? '',
      startYear: data[FirestoreFields.startYear] ?? '',
      graduationYear: data[FirestoreFields.graduationYear],
      profileImageUrl: data[FirestoreFields.profileImageUrl],
      aboutMe: data[FirestoreFields.aboutMe],
      skills: List<String>.from(data[FirestoreFields.skills] ?? []),
      cvUrl: data[FirestoreFields.cvUrl],
      isProfileComplete: data[FirestoreFields.isProfileComplete] ?? false,
      savedListingIds:
          List<String>.from(data[FirestoreFields.savedListingIds] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirestoreFields.fullName: fullName,
      FirestoreFields.university: university,
      FirestoreFields.department: department,
      FirestoreFields.startYear: startYear,
      FirestoreFields.graduationYear: graduationYear,
      FirestoreFields.profileImageUrl: profileImageUrl,
      FirestoreFields.aboutMe: aboutMe,
      FirestoreFields.skills: skills,
      FirestoreFields.cvUrl: cvUrl,
      FirestoreFields.isProfileComplete: isProfileComplete,
      FirestoreFields.savedListingIds: savedListingIds,
    };
  }
}
