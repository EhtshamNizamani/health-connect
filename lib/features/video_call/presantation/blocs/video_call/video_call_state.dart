import 'package:equatable/equatable.dart';
import 'package:health_connect/features/video_call/domain/entity/video_call_enitity.dart';

abstract class VideoCallState extends Equatable {
  const VideoCallState();
  @override
  List<Object?> get props => [];
}

class VideoCallInitial extends VideoCallState {}

// Loading states
class VideoCallInitiating extends VideoCallState {}

class VideoCallLoading extends VideoCallState {}

// Success states
class VideoCallInitiatedSuccess extends VideoCallState {}

// Active calling state (merged from CallingScreenActive)
class VideoCallActive extends VideoCallState {
  final VideoCallEntity callEntity;
  final bool shouldStartAnimations;
  final bool shouldNavigateToCall;

  const VideoCallActive({
    required this.callEntity,
    this.shouldStartAnimations = false,
    this.shouldNavigateToCall = false,
  });

  @override
  List<Object> get props => [callEntity, shouldStartAnimations, shouldNavigateToCall];

  VideoCallActive copyWith({
    VideoCallEntity? callEntity,
    bool? shouldStartAnimations,
    bool? shouldNavigateToCall,
  }) {
    return VideoCallActive(
      callEntity: callEntity ?? this.callEntity,
      shouldStartAnimations: shouldStartAnimations ?? this.shouldStartAnimations,
      shouldNavigateToCall: shouldNavigateToCall ?? this.shouldNavigateToCall,
    );
  }
}

// Navigation state
class VideoCallNavigateToCall extends VideoCallState {
  final String callId;
  final String currentUserId;
  final String currentUserName;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;

  const VideoCallNavigateToCall({
    required this.callId,
    required this.currentUserId,
    required this.currentUserName,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
  });

  @override
  List<Object?> get props => [
        callId,
        currentUserId,
        currentUserName,
        otherUserId,
        otherUserName,
        otherUserPhotoUrl,
      ];
}

// End states - Updated with proper data
class VideoCallCancelled extends VideoCallState {
  final String callId;
  final String message;
  
  const VideoCallCancelled({
    required this.callId,
    required this.message,
  });
  
  @override
  List<Object> get props => [callId, message];
}

class VideoCallDeclined extends VideoCallState {
  final String callId;
  final String message;
  
  const VideoCallDeclined({
    required this.callId,
    required this.message,
  });
  
  @override
  List<Object> get props => [callId, message];
}

class VideoCallFailure extends VideoCallState {
  final String message;
  
  const VideoCallFailure(this.message);
  
  @override
  List<Object> get props => [message];
}