import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/video_call/domain/repository/video_call_repository.dart';

class DeclineCallUseCase {
  final VideoCallRepository repository;
  DeclineCallUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String callerId,
    required String callId,
  }) {
    return repository.declineCall(callerId: callerId, callId: callId);
  }
}