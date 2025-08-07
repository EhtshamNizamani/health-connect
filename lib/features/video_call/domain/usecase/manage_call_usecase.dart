import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:health_connect/features/video_call/domain/repository/call_engine_repository.dart';
import 'package:health_connect/features/video_call/domain/repository/video_call_repository.dart';

class ManageCallUseCase implements UseCase<void, ManageCallParams> {
  final CallEngineRepository _callEngineRepository;
  final VideoCallRepository _videoCallRepository;

  ManageCallUseCase(this._callEngineRepository, this._videoCallRepository);

  @override
  Future<Either<Failure, void>> call(ManageCallParams params) async {
    switch (params.action) {
      case CallAction.initialize:
        return await _callEngineRepository.initializeEngine();
      
      case CallAction.join:
        return await _callEngineRepository.joinRoom(
          params.roomId!,
          params.userId!,
          params.userName!,
        );
      
      case CallAction.leave:
        return await _callEngineRepository.leaveRoom();
      
      case CallAction.endCall:
        final leaveResult = await _callEngineRepository.leaveRoom();
        if (leaveResult.isLeft()) return leaveResult;
        
        return await _videoCallRepository.endCall(
          otherUserId: params.otherUserId!,
          callId: params.roomId!,
        );
      
      case CallAction.toggleCamera:
        return await _callEngineRepository.enableCamera(params.enable!);
      
      case CallAction.toggleMicrophone:
        return await _callEngineRepository.enableMicrophone(params.enable!);
      
      case CallAction.toggleSpeaker:
        return await _callEngineRepository.enableSpeaker(params.enable!);
      
      case CallAction.switchCamera:
        return await _callEngineRepository.switchCamera();
    }
  }
}

class ManageCallParams extends Equatable {
  final CallAction action;
  final String? roomId;
  final String? userId;
  final String? userName;
  final String? otherUserId;
  final bool? enable;

  const ManageCallParams({
    required this.action,
    this.roomId,
    this.userId,
    this.userName,
    this.otherUserId,
    this.enable,
  });

  @override
  List<Object?> get props => [action, roomId, userId, userName, otherUserId, enable];
}

enum CallAction {
  initialize,
  join,
  leave,
  endCall,
  toggleCamera,
  toggleMicrophone,
  toggleSpeaker,
  switchCamera,
}