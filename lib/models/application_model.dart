import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String applicationId;
  final String listingId;
  final String companyId;
  final String studentId;
  final String status; // "Başvuruldu", "İncelendi", "Reddedildi"
  final Timestamp appliedAt;

  final String studentName;
  final String studentUniversity;
  final String? studentCvUrl;

  ApplicationModel({
    required this.applicationId,
    required this.listingId,
    required this.companyId,
    required this.studentId,
    required this.status,
    required this.appliedAt,
    required this.studentName,
    required this.studentUniversity,
    this.studentCvUrl,
  });

  factory ApplicationModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return ApplicationModel(
      applicationId: snap.id,
      listingId: data['listingId'] ?? '',
      companyId: data['companyId'] ?? '',
      studentId: data['studentId'] ?? '',
      status: data['status'] ?? 'Başvuruldu',
      appliedAt: data['appliedAt'] ?? Timestamp.now(),
      studentName: data['studentName'] ?? '',
      studentUniversity: data['studentUniversity'] ?? '',
      studentCvUrl: data['studentCvUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listingId': listingId,
      'companyId': companyId,
      'studentId': studentId,
      'status': status,
      'appliedAt': appliedAt,
      'studentName': studentName,
      'studentUniversity': studentUniversity,
      'studentCvUrl': studentCvUrl,
    };
  }
}
