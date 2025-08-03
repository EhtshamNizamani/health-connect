
import 'package:equatable/equatable.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/video_call/domain/entity/video_call_enitity.dart';
abstract class VideoCallEvent extends Equatable {
  const VideoCallEvent();
  @override
  List<Object?> get props => [];
}

// Original VideoCall Events
class StartCall extends VideoCallEvent {
  final String receiverId;
  final String callerName;
  final String callId;

  const StartCall({
    required this.receiverId,
    required this.callerName,
    required this.callId,
  });

  @override
  List<Object> get props => [receiverId, callerName, callId];
}

class AcceptCall extends VideoCallEvent {
  final String callerId;
  final String callId;

  const AcceptCall({
    required this.callerId,
    required this.callId,
  });

  @override
  List<Object> get props => [callerId, callId];
}

class DeclineCall extends VideoCallEvent {
  final String callerId;
  final String callId;

  const DeclineCall({
    required this.callerId,
    required this.callId,
  });
  
  @override
  List<Object> get props => [callerId, callId];
}

class CancelCall extends VideoCallEvent {
  final String receiverId;
  final String callId;
  
  const CancelCall({
    required this.receiverId,
    required this.callId,
  });
  
  @override
  List<Object> get props => [receiverId, callId];
}

// Original CallingScreen Events (merged)
class InitializeCalling extends VideoCallEvent {
  final String callId;
  final UserEntity currentUser;
  final DoctorEntity doctor;
  final UserEntity patient;

  const InitializeCalling({
    required this.callId,
    required this.currentUser,
    required this.doctor,
    required this.patient,
  });

  @override
  List<Object> get props => [callId, currentUser, doctor, patient];
}

class StartCallingSequence extends VideoCallEvent {}

class JoinCall extends VideoCallEvent {}

class UpdateCallStatus extends VideoCallEvent {
  final VideoCallStatus status;
  
  const UpdateCallStatus(this.status);
  
  @override
  List<Object> get props => [status];
}
