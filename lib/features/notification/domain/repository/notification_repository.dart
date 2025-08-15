import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';

abstract class NotificationRepository {
  // A single method that takes the role
  Stream<Either<Failure, int>> getUnreadCountStream({
    required String userId,
    required String role,
  });

  Future<Either<Failure, void>> markNotificationsAsRead({
    required String userId,
    required String role,
  });
}