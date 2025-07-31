
import 'package:equatable/equatable.dart';

abstract class VideoCallEvent extends Equatable {
  const VideoCallEvent();
  @override
  List<Object> get props => [];
}

/// Event dispatched when the user taps the video call button.
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