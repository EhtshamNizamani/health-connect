import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? photoUrl; // <<<--- NEW FIELD ADDED

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl, // <<<--- ADDED TO CONSTRUCTOR
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String userId) {
    return UserModel(
      id: userId,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'patient',
      photoUrl: map['photoUrl'] as String?, // <<<--- LOGIC ADDED
    );
  }

  // A factory to create from a DocumentSnapshot is often more convenient
  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'patient',
      photoUrl: data['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'photoUrl': photoUrl, // <<<--- FIELD ADDED TO MAP
    };
  }
  
  UserEntity toDomain() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: role,
      photoUrl: photoUrl, // <<<--- FIELD ADDED
    );
  }

  // A new factory to create a Model from an Entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      photoUrl: entity.photoUrl,
    );
  }
}