import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';

class StudentProfileModel {
  final String uid;
  final String fullName;
  final String? university;
  final String? department;
  final String? studentClass;
  final String? startYear;
  final String? graduationYear;
  final String? profileImageUrl;
  final String? aboutMe;
  final List<String>? skills;
  final String? cvUrl;
  final bool? isProfileComplete;
  final List<String>? savedListingIds;

  StudentProfileModel({
    required this.uid,
    required this.fullName,
    this.university,
    this.department,
    this.studentClass,
    this.startYear,
    this.graduationYear,
    this.profileImageUrl,
    this.aboutMe,
    this.skills,
    this.cvUrl,
    this.isProfileComplete,
    this.savedListingIds,
  });

  StudentProfileModel copyWith({
    String? uid,
    String? fullName,
    String? university,
    String? department,
    String? studentClass,
    String? startYear,
    String? graduationYear,
    String? profileImageUrl,
    String? aboutMe,
    List<String>? skills,
    String? cvUrl,
    bool? isProfileComplete,
    List<String>? savedListingIds,
  }) {
    return StudentProfileModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      university: university ?? this.university,
      department: department ?? this.department,
      studentClass: studentClass ?? this.studentClass,
      startYear: startYear ?? this.startYear,
      graduationYear: graduationYear ?? this.graduationYear,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      aboutMe: aboutMe ?? this.aboutMe,
      skills: skills ?? this.skills,
      cvUrl: cvUrl ?? this.cvUrl,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      savedListingIds: savedListingIds ?? this.savedListingIds,
    );
  }

  factory StudentProfileModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return StudentProfileModel(
      uid: snap.id,
      fullName: data[FirestoreStudentFields.fullName] ?? '',
      university: data[FirestoreStudentFields.university] ?? '',
      department: data[FirestoreStudentFields.department] ?? '',
      studentClass: data[FirestoreStudentFields.studentClass] ?? '',
      startYear: data[FirestoreStudentFields.startYear] ?? '',
      graduationYear: data[FirestoreStudentFields.graduationYear],
      profileImageUrl: data[FirestoreStudentFields.profileImageUrl],
      aboutMe: data[FirestoreStudentFields.aboutMe],
      skills: List<String>.from(data[FirestoreStudentFields.skills] ?? []),
      cvUrl: data[FirestoreStudentFields.cvUrl],
      isProfileComplete:
          data[FirestoreStudentFields.isProfileComplete] ?? false,
      savedListingIds:
          List<String>.from(data[FirestoreStudentFields.savedListingIds] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirestoreStudentFields.fullName: fullName,
      FirestoreStudentFields.university: university,
      FirestoreStudentFields.department: department,
      FirestoreStudentFields.studentClass: studentClass,
      FirestoreStudentFields.startYear: startYear,
      FirestoreStudentFields.graduationYear: graduationYear,
      FirestoreStudentFields.profileImageUrl: profileImageUrl,
      FirestoreStudentFields.aboutMe: aboutMe,
      FirestoreStudentFields.skills: skills,
      FirestoreStudentFields.cvUrl: cvUrl,
      FirestoreStudentFields.isProfileComplete: isProfileComplete,
      FirestoreStudentFields.savedListingIds: savedListingIds,
    };
  }
}
