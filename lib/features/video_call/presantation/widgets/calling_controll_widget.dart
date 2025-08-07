import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_connect/features/video_call/domain/entity/video_call_enitity.dart';

class CallingControlsWidget extends StatelessWidget {
  final VideoCallStatus callState;
  final VoidCallback onCancel;

  const CallingControlsWidget({
    Key? key,
    required this.callState,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Row(
        mainAxisAlignment: _shouldCenterControls()
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceEvenly,
        children: [
          // Cancel/End call button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onCancel();
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red,
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          
          // Additional controls can be added here if needed
          // For example, mute button during ringing state
        ],
      ),
    );
  }

  bool _shouldCenterControls() {
    return callState == VideoCallStatus.connecting || 
           callState == VideoCallStatus.connectingToCall;
  }
}
