import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/video_call/domain/repository/video_call_repository.dart';

class InitiateCallUseCase {
  final VideoCallRepository repository;
  InitiateCallUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String receiverId,
    required String callerName,
    required String callId,
  }) {
    return repository.initiateCall(
      receiverId: receiverId,
      callerName: callerName,
      callId: callId,
    );
  }
}