import 'package:equatable/equatable.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
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

class NavigateToCallingScreen extends VideoCallState {
  final String callId;
  final UserEntity currentUser;
  final DoctorEntity doctor;
  final UserEntity patient;

  const NavigateToCallingScreen({
    required this.callId,
    required this.currentUser,
    required this.doctor,
    required this.patient,
  });
  
  @override
  List<Object> get props => [callId, currentUser, doctor, patient];
}

// YEH STATE UI BUILD KARTI HAI (CallingScreen ka UI)
class VideoCallActive extends VideoCallState {
  final VideoCallEntity callEntity;
  final bool shouldStartAnimations;

  const VideoCallActive({
    required this.callEntity,
    this.shouldStartAnimations = false,
  });

  @override
  List<Object> get props => [callEntity, shouldStartAnimations];

  VideoCallActive copyWith({
    VideoCallEntity? callEntity,
    bool? shouldStartAnimations,
  }) {
    return VideoCallActive(
      callEntity: callEntity ?? this.callEntity,
      shouldStartAnimations: shouldStartAnimations ?? this.shouldStartAnimations,
    );
  }
}


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