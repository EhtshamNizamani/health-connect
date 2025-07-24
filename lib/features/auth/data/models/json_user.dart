import 'package:health_connect/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // Factory constructor to create a UserModel from a Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map, String userId) {
    return UserModel(
      id: userId, // It's often safer to pass the document ID separately
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'patient', // Default to 'patient' if role is missing
    );
  }

  // A method to convert the UserModel to a Firestore Map
  // This is useful when creating/updating the user document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }
  
  // THE MOST IMPORTANT METHOD:
  // Converts the Data layer object (Model) to a Domain layer object (Entity)
  UserEntity toDomain() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: role,
    );
  }
}