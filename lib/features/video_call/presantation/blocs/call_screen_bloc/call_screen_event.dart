
import 'package:equatable/equatable.dart';

abstract class CallScreenEvent extends Equatable {
  const CallScreenEvent();
  @override
  List<Object?> get props => [];
}

class InitializeCall extends CallScreenEvent {
  final String callId;
  final String userId;
  final String userName;
  const InitializeCall(this.callId, this.userId, this.userName);
  @override
  List<Object> get props => [callId, userId, userName];
}

class ToggleCamera extends CallScreenEvent {
  final bool enable;
  const ToggleCamera(this.enable);
  @override
  List<Object> get props => [enable];
}

class ToggleMicrophone extends CallScreenEvent {
  final bool enable;
  const ToggleMicrophone(this.enable);
  @override
  List<Object> get props => [enable];
}

class ToggleSpeaker extends CallScreenEvent {
  final bool enable;
  const ToggleSpeaker(this.enable);
  @override
  List<Object> get props => [enable];
}

class SwitchCamera extends CallScreenEvent {}

class EndCall extends CallScreenEvent {
  final String otherUserId;
  const EndCall(this.otherUserId);
  @override
  List<Object> get props => [otherUserId];
}

class ToggleControlsVisibility extends CallScreenEvent {}