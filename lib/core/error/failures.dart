abstract class Failure {
  final String message;
  Failure(this.message);
}

class AuthFailure extends Failure {
  AuthFailure(super.message);
}

class DoctorProfileFailure extends Failure {
  DoctorProfileFailure(super.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class FirestoreFailure extends Failure {
  FirestoreFailure(super.message);
}

class StorageFailure extends Failure {
  StorageFailure(super.message);
}

class ValidationError extends Failure {
  ValidationError(super.message);
}
class UnexpectedFailure extends Failure {
  UnexpectedFailure(super.message);
}