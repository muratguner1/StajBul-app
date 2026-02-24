import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/firestore_constants.dart';
import 'package:staj_bul_demo/core/constants/user_roles.dart';

class UserModel {
  final String uid;
  final String email;
  final String role;
  final Timestamp createdAt;

  final String? phone;
  final String? linkedin;
  final String? github;
  final String? address;
  final String? portfolio;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    this.phone,
    this.linkedin,
    this.github,
    this.address,
    this.portfolio,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return UserModel(
      uid: snap.id,
      email: data[FirestoreUserFields.email] ?? '',
      role: data[FirestoreUserFields.role] ?? UserRoles.student,
      createdAt: data[FirestoreUserFields.createdAt] ?? Timestamp.now(),
      phone: data[FirestoreUserFields.phone],
      linkedin: data[FirestoreUserFields.linkedin],
      github: data[FirestoreUserFields.github],
      address: data[FirestoreUserFields.address],
      portfolio: data[FirestoreUserFields.portfolio],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirestoreUserFields.email: email,
      FirestoreUserFields.role: role,
      FirestoreUserFields.createdAt: createdAt,
      FirestoreUserFields.phone: phone,
      FirestoreUserFields.linkedin: linkedin,
      FirestoreUserFields.github: github,
      FirestoreUserFields.address: address,
      FirestoreUserFields.portfolio: portfolio,
    };
  }
}
