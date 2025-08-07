import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';

abstract class VideoCallRepository {
  Future<Either<Failure, void>> initiateCall({
    required String receiverId,
    required String callerName,
    required String callId,
  });

  Future<Either<Failure, void>> acceptCall({
    required String callerId,
    required String callId,
  });

  Future<Either<Failure, void>> endCall({
    required String otherUserId,
    required String callId,
  });
  Future<Either<Failure, void>> declineCall({
    required String callerId,
    required String callId,
  }); // ADD
  Future<Either<Failure, void>> cancelCall({
    required String receiverId,
    required String callId,
  }); // ADD
}
