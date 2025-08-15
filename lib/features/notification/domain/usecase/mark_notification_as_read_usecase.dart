import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:health_connect/features/notification/domain/repository/notification_repository.dart';

class MarkNotificationsAsReadUseCase implements UseCase<void, MarkNotificationsAsReadParams> {
  final NotificationRepository repository;
  MarkNotificationsAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkNotificationsAsReadParams params) async {
    return await repository.markNotificationsAsRead(
      userId: params.userId,
      role: params.role,
    );
  }
}

class MarkNotificationsAsReadParams extends Equatable {
  final String userId;
  final String role;
  const MarkNotificationsAsReadParams({required this.userId, required this.role});
  @override
  List<Object> get props => [userId, role];
}