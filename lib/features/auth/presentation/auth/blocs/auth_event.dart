abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password, });
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String selectedRole;
  RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.selectedRole, // 'doctor' or 'patient'
  });
}

class LogoutRequested extends AuthEvent {}