import 'package:equatable/equatable.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/video_call/domain/entity/calling_entity.dart';

abstract class CallingScreenEvent extends Equatable {
  const CallingScreenEvent();
  @override
  List<Object?> get props => [];
}

class InitializeCalling extends CallingScreenEvent {
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

class StartCallingSequence extends CallingScreenEvent {}

class CancelCalling extends CallingScreenEvent {}

class JoinCall extends CallingScreenEvent {}

class UpdateCallState extends CallingScreenEvent {
  final CallState callState;
  const UpdateCallState(this.callState);
  @override
  List<Object> get props => [callState];
}
