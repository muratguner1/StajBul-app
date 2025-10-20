import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfileModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String university;
  final String department;
  final int startYear;
  final int? graduationYear;
  final String? profilePhotoUrl;
  final String? aboutMe;
  final List<String> skills;
  final String? cvUrl;
  final bool isProfileComplete;
  final List<String> savedListingIds;

  StudentProfileModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.university,
    required this.department,
    required this.startYear,
    this.graduationYear,
    this.profilePhotoUrl,
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
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      university: data['university'] ?? '',
      department: data['department'] ?? '',
      startYear: data['startYear'] ?? '',
      graduationYear: data['graduationYear'],
      profilePhotoUrl: data['profilePhotoUrl'],
      aboutMe: data['aboutMe'],
      skills: List<String>.from(data['skills'] ?? []),
      cvUrl: data['cvUrl'],
      isProfileComplete: data['isProfileComplete'] ?? false,
      savedListingIds: List<String>.from(data['savedListingIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'university': university,
      'department': department,
      'startYear': startYear,
      'graduationYear': graduationYear,
      'profilePhotoUrl': profilePhotoUrl,
      'aboutMe': aboutMe,
      'skills': skills,
      'cvUrl': cvUrl,
      'isProfileComplete': isProfileComplete,
      'savedListingIds': savedListingIds,
    };
  }
}
