import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/chat/domain/repositories/chat_repository.dart';

class GetTotalUnreadCountUseCase {
  final ChatRepository repository;

  GetTotalUnreadCountUseCase(this.repository);

  Stream<Either<Failure, int>> call(String userId) {
    return repository.getTotalUnreadCountStream(userId);
  }
}