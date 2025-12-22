import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staj_bul_demo/core/constants/user_roles.dart';

class UserModel {
  final String uid;
  final String email;
  final String role;
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return UserModel(
      uid: snap.id,
      email: data['email'] ?? '',
      role: data['role'] ?? UserRoles.student,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'role': role,
      'createdAt': createdAt,
    };
  }
}
