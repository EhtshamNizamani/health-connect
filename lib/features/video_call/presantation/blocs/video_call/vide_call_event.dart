import 'package:equatable/equatable.dart';

abstract class VideoCallEvent extends Equatable {
  const VideoCallEvent();
  @override
  List<Object> get props => [];
}

/// Dispatched when the user taps the call icon to start a call.
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

/// Dispatched when the receiver taps "Accept".
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

/// Dispatched when the receiver taps "Decline".
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

/// Dispatched when the caller cancels the call from the CallingScreen.
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