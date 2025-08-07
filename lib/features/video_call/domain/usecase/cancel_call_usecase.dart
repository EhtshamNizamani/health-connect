import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/video_call/domain/repository/video_call_repository.dart';

class CancelCallUseCase {
  final VideoCallRepository repository;
  CancelCallUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String receiverId,
    required String callId,
  }) {
    return repository.cancelCall(receiverId: receiverId, callId: callId);
  }
}