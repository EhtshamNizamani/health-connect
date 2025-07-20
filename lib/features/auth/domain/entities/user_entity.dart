class UserEntity {
  final String id;
  final String name;
  final String email;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, email: $email)';
  }
}