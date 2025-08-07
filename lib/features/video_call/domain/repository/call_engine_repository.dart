import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';

import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/video_call/domain/entity/call_engine_event.dart';

abstract class CallEngineRepository {
    Future<Either<Failure, void>> initializeEngine();
  Future<Either<Failure, void>> joinRoom(String roomId, String userId, String userName);
  Future<Either<Failure, void>> leaveRoom();
  Future<Either<Failure, void>> enableCamera(bool enable);
  Future<Either<Failure, void>> enableMicrophone(bool enable);
  Future<Either<Failure, void>> enableSpeaker(bool enable);
  Future<Either<Failure, void>> switchCamera();
  Future<Either<Failure, Widget?>> createLocalView();
  Future<Either<Failure, Widget?>> createRemoteView(String streamId);
  Future<Either<Failure, void>> destroyEngine();
  Stream<CallEngineEvent> get engineEvents;
  
}