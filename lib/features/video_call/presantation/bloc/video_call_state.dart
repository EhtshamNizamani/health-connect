
import 'package:equatable/equatable.dart';

abstract class VideoCallState extends Equatable {
  const VideoCallState();
  @override
  List<Object> get props => [];
}

/// The initial state, nothing has happened yet.
class VideoCallInitial extends VideoCallState {}

/// The state when the Cloud Function is being called.
/// The UI can use this to show a loading indicator.
class VideoCallInitiating extends VideoCallState {}

/// The state when the Cloud Function call was successful.
/// The UI will listen for this state to navigate to the CallingScreen.
class VideoCallInitiatedSuccess extends VideoCallState {}

/// The state when something went wrong.
/// The UI will listen for this to show an error message.
class VideoCallFailure extends VideoCallState {
  final String message;
  const VideoCallFailure(this.message);
  @override
  List<Object> get props => [message];
}