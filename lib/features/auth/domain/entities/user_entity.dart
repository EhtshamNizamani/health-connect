class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role; // 'doctor' or 'patient'

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });


  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, email: $email, role: $role)';
  }
}