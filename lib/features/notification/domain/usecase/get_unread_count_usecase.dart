import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/notification/domain/repository/notification_repository.dart';
class GetUnreadCountUseCase {
  final NotificationRepository repository;
  GetUnreadCountUseCase(this.repository);

  // FIXED: Changed parameter order to match repository (userId first, role second)
  Stream<Either<Failure, int>> call(String userId, String role) {
    return repository.getUnreadCountStream(userId: userId, role: role);
  }
}