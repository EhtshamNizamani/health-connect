import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role; // 'doctor' or 'patient'

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, email, role];
  
  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, email: $email, role: $role)';
  }
}