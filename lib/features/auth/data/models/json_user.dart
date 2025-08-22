import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? photoUrl;

  // <<< --- NEW FIELDS ---
  final String? allergies;
  final String? chronicConditions;
  final String? age;
  final String? gender;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.allergies,
    this.chronicConditions,
    this.age,
    this.gender,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String userId) {
    return UserModel(
      id: userId,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'patient',
      photoUrl: map['photoUrl'] as String?,
      allergies: map['allergies'] as String?,
      chronicConditions: map['chronicConditions'] as String?,
      age: map['age'] as String?,
      gender: map['gender'] as String?,
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'patient',
      photoUrl: data['photoUrl'] as String?,
      allergies: data['allergies'] as String?,
      chronicConditions: data['chronicConditions'] as String?,
      age: data['age'] as String?,
      gender: data['gender'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'age': age,
      'gender': gender,
    };
  }

  UserEntity toDomain() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: role,
      photoUrl: photoUrl,
      allergies: allergies,
      chronicConditions: chronicConditions,
      age: age,
      gender: gender,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      photoUrl: entity.photoUrl,
      allergies: entity.allergies,
      chronicConditions: entity.chronicConditions,
      age: entity.age,
      gender: entity.gender,
    );
  }
}
