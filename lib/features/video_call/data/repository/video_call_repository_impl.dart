import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/video_call/domain/repository/video_call_repository.dart';

class VideoCallRepositoryImpl implements VideoCallRepository {
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  VideoCallRepositoryImpl(this._functions, this._auth);

  @override
  Future<Either<Failure, void>> initiateCall({
    required String receiverId,
    required String callerName,
    required String callId,
  }) async {
    try {
      // --- THE GUARANTEED FIX: FORCE TOKEN REFRESH ---

      // 1. Get the current user object from the SDK.
      final user = _auth.currentUser;

      // 2. Check if the user is logged in on the device.
      if (user == null) {
        return Left(ServerFailure("You are not logged in."));
      }

      // 3. FORCE the SDK to get a fresh ID token from Firebase servers.
      //    The 'true' argument means "force refresh".
      //    This guarantees the token attached to the function call is valid.
      print("Forcing token refresh before calling function...");
      await user.getIdToken(true);
      print("Token refreshed successfully.");

      // 4. Now, it is safe to call the Cloud Function.
      final HttpsCallable callable = _functions.httpsCallable(
        'sendCallNotification',
      );
      print("Calling cloud function...");
      await callable.call<void>({
        'receiverId': receiverId,
        'callerName': callerName,
        'callId': callId,
      });

      print("Successfully called Cloud Function.");
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      print(
        "FirebaseFunctionsException: Code: ${e.code}, Message: ${e.message}",
      );
      return Left(ServerFailure("Cloud Function Error: ${e.message}"));
    } catch (e) {
      print("An unknown error occurred: $e");
      return Left(ServerFailure("An unknown error occurred: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> acceptCall({
    required String callerId,
    required String callId,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('acceptCall');
      await callable.call<void>({'callerId': callerId, 'callId': callId});
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure("Functions Error: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unknown error occurred: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> endCall({
    required String otherUserId,
    required String callId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Left(ServerFailure("You are not logged in."));
      }

      await user.getIdToken(true);

      final HttpsCallable callable = _functions.httpsCallable('endCall');
      await callable.call<void>({'otherUserId': otherUserId, 'callId': callId});

      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure("Functions Error: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unknown error occurred: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> cancelCall({
    required String receiverId,
    required String callId,
  }) async {
    try {
      

      final HttpsCallable callable = _functions.httpsCallable('cancelCall');
      await callable.call<void>({'receiverId': receiverId, 'callId': callId});

      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure("Cancel call error: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unknown error occurred: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> declineCall({
    required String callerId,
    required String callId,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('declineCall');
      await callable.call<void>({'callerId': callerId, 'callId': callId});
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure("Functions Error: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unknown error occurred: $e"));
    }
  }
}
