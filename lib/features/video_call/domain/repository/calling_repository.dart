import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';

abstract class CallingRepository {
  Future<Either<Failure, void>> cancelCall({
    required String receiverId,
    required String callId,
  });
  
  Future<Either<Failure, void>> sendCallAnswer({
    required String callerId,
    required String callId,
    required bool accepted,
  });
  
  Future<Either<Failure, void>> sendCallRejection({
    required String callerId,
    required String callId,
  });
}
