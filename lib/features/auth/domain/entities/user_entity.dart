import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? photoUrl; // <<<--- NEW FIELD ADDED

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl, // <<<--- ADDED TO CONSTRUCTOR
  });

  @override
  List<Object?> get props => [id, name, email, role, photoUrl]; // <<<--- ADDED TO PROPS
  
  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, email: $email, role: $role, photoUrl: $photoUrl)';
  }
}