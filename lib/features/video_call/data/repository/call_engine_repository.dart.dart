import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/utils/token_generater.dart';
import 'package:health_connect/features/video_call/domain/entity/call_engine_event.dart';
import 'package:health_connect/features/video_call/domain/repository/call_engine_repository.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:health_connect/core/config/zego_cloud_config.dart';

class CallEngineRepositoryImpl implements CallEngineRepository {
  final ZegoConfig _zegoConfig;
  bool _isEngineCreated = false;
  final StreamController<CallEngineEvent> _eventController = StreamController.broadcast();

  CallEngineRepositoryImpl(this._zegoConfig);

  @override
  Stream<CallEngineEvent> get engineEvents => _eventController.stream;

  @override
  Future<Either<Failure, void>> initializeEngine() async {
    try {
      if (_isEngineCreated) return const Right(null);

      await ZegoExpressEngine.createEngineWithProfile(
        ZegoEngineProfile(
          _zegoConfig.appId,
          ZegoScenario.Communication,
          appSign: _zegoConfig.appSign,
        ),
      );

      await _configureEngine();
      _setupEventListeners();
      _isEngineCreated = true;
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to initialize engine: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> joinRoom(String roomId, String userId, String userName) async {
   
    try {
      final user = ZegoUser(userId, userName);
      final token =  ZegoTokenGenerator.generateToken(appId: _zegoConfig.appId, serverSecret: _zegoConfig.serverSecret, userId: userId);  
      
      final config = ZegoRoomConfig.defaultConfig()
        ..isUserStatusNotify = true
        ..token = token;

      final result = await ZegoExpressEngine.instance.loginRoom(roomId, user, config: config);
      
      if (result.errorCode == 0) {
        await _startPreviewAndPublish(userId, roomId);
        return const Right(null);
      } else {
        return Left(ServerFailure('Failed to join room: ${result.errorCode}'));
      }
    } catch (e) {
      return Left(ServerFailure('Room join error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveRoom() async {
    try {
      await ZegoExpressEngine.instance.stopPreview();
      await ZegoExpressEngine.instance.stopPublishingStream();
      await ZegoExpressEngine.instance.logoutRoom();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Leave room error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> enableCamera(bool enable) async {
    try {
      await ZegoExpressEngine.instance.enableCamera(enable);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Camera toggle error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> enableMicrophone(bool enable) async {
    try {
      await ZegoExpressEngine.instance.muteMicrophone(!enable);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Microphone toggle error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> enableSpeaker(bool enable) async {
    try {
      await ZegoExpressEngine.instance.muteSpeaker(!enable);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Speaker toggle error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> switchCamera() async {
    try {
      await ZegoExpressEngine.instance.useFrontCamera(true);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Switch camera error: $e'));
    }
  }

  @override
  Future<Either<Failure, Widget?>> createLocalView() async {
    try {
      final widget = await ZegoExpressEngine.instance.createCanvasView((viewID) {
        final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFit);
        ZegoExpressEngine.instance.startPreview(canvas: canvas);
      });
      return Right(widget);
    } catch (e) {
      return Left(ServerFailure('Create local view error: $e'));
    }
  }

  @override
  Future<Either<Failure, Widget?>> createRemoteView(String streamId) async {
    try {
      final widget = await ZegoExpressEngine.instance.createCanvasView((viewID) {
        final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFit);
        ZegoExpressEngine.instance.startPlayingStream(streamId, canvas: canvas);
      });
      return Right(widget);
    } catch (e) {
      return Left(ServerFailure('Create remote view error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> destroyEngine() async {
    try {
      if (_isEngineCreated) {
        await ZegoExpressEngine.destroyEngine();
        _isEngineCreated = false;
      }
      _eventController.close();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Destroy engine error: $e'));
    }
  }

  Future<void> _configureEngine() async {
    await ZegoExpressEngine.instance.enableHardwareEncoder(true);
    await ZegoExpressEngine.instance.enableHardwareDecoder(true);
    
    await ZegoExpressEngine.instance.setVideoConfig(
      ZegoVideoConfig(720, 1280, 720, 1280, 2000, 30, ZegoVideoCodecID.H265),
    );
    
    await ZegoExpressEngine.instance.setAudioConfig(
      ZegoAudioConfig(128, ZegoAudioChannel.Stereo, ZegoAudioCodecID.Normal2),
    );
  }

  void _setupEventListeners() {
    ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, userList) {
      _eventController.add(UserUpdateEvent(updateType, userList));
    };

    ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, streamList, extendedData) {
      _eventController.add(StreamUpdateEvent(updateType, streamList));
    };

    ZegoExpressEngine.onRoomStateUpdate = (roomID, state, errorCode, extendedData) {
      _eventController.add(RoomStateUpdateEvent(state, errorCode));
    };
  }



  Future<void> _startPreviewAndPublish(String userId, String roomId) async {
    await ZegoExpressEngine.instance.enableCamera(true);
    await ZegoExpressEngine.instance.muteMicrophone(false);
    
    final streamId = '${roomId}_${userId}_stream';
    await ZegoExpressEngine.instance.startPublishingStream(streamId);
  }
}
