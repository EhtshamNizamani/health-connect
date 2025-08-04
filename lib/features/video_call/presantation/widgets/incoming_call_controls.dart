import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/vide_call_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/vide_call_state.dart';
import 'package:health_connect/features/video_call/presantation/widgets/incoming_call_buttons.dart';

class IncomingCallControls extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onMessage;

  const IncomingCallControls({
    super.key,
    required this.onAccept,
    required this.onDecline,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoCallBloc, VideoCallState>(
      builder: (context, state) {
        final isLoading = state is VideoCallInitiating;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Decline button
              IncomingCallActionButton(
                icon: Icons.call_end,
                color: Colors.red,
                size: 70,
                onTap: onDecline,
                isLoading: isLoading,
              ),
              
              // Message button (optional)
              IncomingCallSecondaryButton(
                icon: Icons.message,
                onTap: onMessage,
              ),
              
              // Accept button
              IncomingCallActionButton(
                icon: Icons.videocam,
                color: Colors.green,
                size: 70,
                onTap: onAccept,
                isLoading: isLoading,
              ),
            ],
          ),
        );
      },
    );
  }
}
