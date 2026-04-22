import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/common.dart';

class ApplicationModel {
  final String applicationId;
  final String postId;
  final String companyId;
  final String studentId;
  final String status; // "Başvuruldu", "İncelendi", "Reddedildi"
  final Timestamp appliedAt;

  final String studentName;
  final double? matchScore;
  final String studentUniversity;
  final List<String> studentSkills;
  final String? studentCvUrl;

  ApplicationModel({
    required this.applicationId,
    required this.postId,
    required this.companyId,
    required this.studentId,
    required this.status,
    required this.appliedAt,
    required this.studentName,
    required this.studentUniversity,
    required this.matchScore,
    required this.studentSkills,
    this.studentCvUrl,
  });

  factory ApplicationModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return ApplicationModel(
      applicationId: snap.id,
      postId: data[FireStorePostFields.postId] ?? '',
      companyId: data[FirestoreCompanyFields.companyId] ?? '',
      studentId: data[FirestoreStudentFields.studentId] ?? '',
      status: data[FireStoreApplicationFields.status] ?? 'Başvuruldu',
      appliedAt: data[FireStoreApplicationFields.appliedAt] ?? Timestamp.now(),
      studentName: data[FirestoreStudentFields.fullName] ?? '',
      studentUniversity: data[FirestoreStudentFields.university] ?? '',
      studentCvUrl: data[FirestoreStudentFields.cvUrl] ?? '',
      matchScore: data[FireStoreApplicationFields.matchScore] ?? 0.0,
      studentSkills:
          List<String>.from(data[FirestoreStudentFields.skills] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FireStorePostFields.postId: postId,
      FirestoreCompanyFields.companyId: companyId,
      FirestoreStudentFields.studentId: studentId,
      FireStoreApplicationFields.status: status,
      FireStoreApplicationFields.appliedAt: appliedAt,
      FirestoreStudentFields.fullName: studentName,
      FirestoreStudentFields.university: studentUniversity,
      FirestoreStudentFields.cvUrl: studentCvUrl,
      FireStoreApplicationFields.matchScore: matchScore,
      FirestoreStudentFields.skills: studentSkills,
    };
  }
}
