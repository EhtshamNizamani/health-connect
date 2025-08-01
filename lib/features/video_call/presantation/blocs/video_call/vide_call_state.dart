
import 'package:equatable/equatable.dart';

abstract class VideoCallState extends Equatable {
  const VideoCallState();
  @override
  List<Object> get props => [];
}

class VideoCallInitial extends VideoCallState {}

class VideoCallInitiating extends VideoCallState {}

class VideoCallInitiatedSuccess extends VideoCallState {}

class VideoCallFailure extends VideoCallState {
  final String message;
  const VideoCallFailure(this.message);
  @override
  List<Object> get props => [message];
}