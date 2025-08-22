import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? photoUrl; 
  final String? allergies;
  final String? chronicConditions;
  final String? age;
  final String? gender;
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.age,
    this.allergies,
    this.chronicConditions,
    this.gender,
  });

  // Empty constructor
  const UserEntity.empty()
    : id = '',
      name = '',
      email = '',
      role = '',
      photoUrl = null,
      age = null,
      allergies = null,
      chronicConditions = null,
      gender = null;

  @override
  List<Object?> get props => [id, name, email, role, photoUrl, age, allergies, chronicConditions, gender]; // <<<--- ADDED TO PROPS

  // @override
  // String toString() {
  //   return 'UserEntity(id: $id, name: $name, email: $email, role: $role, photoUrl: $photoUrl)';
  // }
}
