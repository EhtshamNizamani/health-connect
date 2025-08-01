import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_event.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_state.dart';
import 'package:health_connect/features/video_call/presantation/widgets/call_controller_widget.dart';
import 'package:health_connect/features/video_call/presantation/widgets/call_topbar_widget.dart';
import 'package:health_connect/features/video_call/presantation/widgets/call_video_widget.dart';

class CallContentWidget extends StatelessWidget {
  final CallScreenConnected state;
  final UserEntity currentUser;
  final UserEntity otherUser;
  final String callId;

  const CallContentWidget({
    Key? key,
    required this.state,
    required this.currentUser,
    required this.otherUser,
    required this.callId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<CallScreenBloc>().add(ToggleControlsVisibility());
      },
      child: Stack(
        children: [
          // Main video view
          CallVideoWidget(
            localView: state.localView,
            remoteView: state.remoteView,
            otherUser: otherUser,
            connectionStatus: state.connectionStatus,
          ),

          // Top bar with user info and call duration
          if (state.showControls)
            CallTopBarWidget(
              otherUser: otherUser,
              callDurationSeconds: state.callDurationSeconds,
              connectionStatus: state.connectionStatus,
            ),

          // Bottom controls
          if (state.showControls)
            CallControlsWidget(
              isCameraEnabled: state.isCameraEnabled,
              isMicEnabled: state.isMicEnabled,
              isSpeakerEnabled: state.isSpeakerEnabled,
              onCameraToggle: (enabled) {
                context.read<CallScreenBloc>().add(ToggleCamera(enabled));
              },
              onMicToggle: (enabled) {
                context.read<CallScreenBloc>().add(ToggleMicrophone(enabled));
              },
              onSpeakerToggle: (enabled) {
                context.read<CallScreenBloc>().add(ToggleSpeaker(enabled));
              },
              onSwitchCamera: () {
                context.read<CallScreenBloc>().add(SwitchCamera());
              },
              onEndCall: () {
                context.read<CallScreenBloc>().add(EndCall(otherUser.id));
              },
            ),
        ],
      ),
    );
  }
}

