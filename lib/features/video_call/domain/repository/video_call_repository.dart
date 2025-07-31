import 'package:dartz/dartz.dart';

import 'package:health_connect/core/error/failures.dart';

abstract class VideoCallRepository {
  /// Initiates a video call by sending an invitation to the receiver.
  Future<Either<Failure, void>> initiateCall({
    required String receiverId,
    required String callerName,
    required String callId,
  });
    Future<Either<Failure, void>> acceptCall({
    required String callerId,
    required String callId,
  });
}