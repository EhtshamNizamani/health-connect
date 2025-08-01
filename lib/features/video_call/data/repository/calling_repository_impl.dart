import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/video_call/domain/repository/calling_repository.dart';

class CallingRepositoryImpl implements CallingRepository {
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  CallingRepositoryImpl(this._functions, this._auth);

  @override
  Future<Either<Failure, void>> cancelCall({
    required String receiverId,
    required String callId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Left(ServerFailure("You are not logged in."));
      }

      await user.getIdToken(true);

      final HttpsCallable callable = _functions.httpsCallable('cancelCall');
      await callable.call<void>({
        'receiverId': receiverId,
        'callId': callId,
      });

      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure("Cancel call error: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unknown error occurred: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> sendCallAnswer({
    required String callerId,
    required String callId,
    required bool accepted,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Left(ServerFailure("You are not logged in."));
      }

      await user.getIdToken(true);

      final HttpsCallable callable = _functions.httpsCallable('answerCall');
      await callable.call<void>({
        'callerId': callerId,
        'callId': callId,
        'accepted': accepted,
      });

      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure("Answer call error: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unknown error occurred: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> sendCallRejection({
    required String callerId,
    required String callId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Left(ServerFailure("You are not logged in."));
      }

      await user.getIdToken(true);

      final HttpsCallable callable = _functions.httpsCallable('rejectCall');
      await callable.call<void>({
        'callerId': callerId,
        'callId': callId,
      });

      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure("Reject call error: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unknown error occurred: $e"));
    }
  }
}
