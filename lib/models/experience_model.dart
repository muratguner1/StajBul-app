import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';

class ExperienceModel {
  final String id;
  final String company;
  final String position;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;

  ExperienceModel({
    required this.id,
    required this.company,
    required this.position,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
  });

  factory ExperienceModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExperienceModel(
        id: doc.id,
        company: data[FireStoreExperienceFields.company] ?? '',
        position: data[FireStoreExperienceFields.position] ?? '',
        description: data[FireStoreExperienceFields.description] ?? '',
        startDate:
            (data[FireStoreExperienceFields.startDate] as Timestamp).toDate(),
        endDate: data[FireStoreExperienceFields.endDate] != null
            ? (data[FireStoreExperienceFields.endDate] as Timestamp).toDate()
            : null,
        isCurrent: data[FireStoreExperienceFields.isCurrent] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      FireStoreExperienceFields.company: company,
      FireStoreExperienceFields.position: position,
      FireStoreExperienceFields.description: description,
      FireStoreExperienceFields.startDate: Timestamp.fromDate(startDate),
      FireStoreExperienceFields.endDate:
          endDate != null ? Timestamp.fromDate(endDate!) : null,
      FireStoreExperienceFields.isCurrent: isCurrent,
      FireStoreExperienceFields.createdAt: FieldValue.serverTimestamp(),
    };
  }

  ExperienceModel copyWith({
    String? id,
    String? company,
    String? position,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
  }) {
    return ExperienceModel(
      id: id ?? this.id,
      company: company ?? this.company,
      position: position ?? this.position,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}
