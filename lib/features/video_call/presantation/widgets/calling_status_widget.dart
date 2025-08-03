import 'package:flutter/material.dart';
import 'package:health_connect/features/video_call/domain/entity/calling_entity.dart';
import 'package:health_connect/features/video_call/domain/entity/video_call_enitity.dart';

class CallingStatusWidget extends StatelessWidget {
  final VideoCallStatus callState;

  const CallingStatusWidget({
    Key? key,
    required this.callState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _getCallStatusMessage(),
        key: ValueKey(callState),
        style: TextStyle(
          fontSize: 18,
          color: Colors.white.withOpacity(0.8),
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getCallStatusMessage() {
    switch (callState) {
      case VideoCallStatus.connecting:
        return "Connecting...";
      case VideoCallStatus.ringing:
        return "Ringing...";
      case VideoCallStatus.connectingToCall:
        return "Joining call...";
      case VideoCallStatus.connected:
        return "Connected";
      case VideoCallStatus.ended:
        return "Call ended";
      case VideoCallStatus.cancelled:
        return "Call cancelled";
      case VideoCallStatus.busy:
        return "User is busy";
      case VideoCallStatus.noAnswer:
        return "No answer";
      case VideoCallStatus.initiating:
        return "Initiating";
      case VideoCallStatus.failed:
        return "Fialed";
    }
  }
}

