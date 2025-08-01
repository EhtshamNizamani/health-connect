import 'package:flutter/material.dart';
import 'package:health_connect/features/video_call/domain/entity/calling_entity.dart';

class CallingStatusWidget extends StatelessWidget {
  final CallState callState;

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
      case CallState.connecting:
        return "Connecting...";
      case CallState.ringing:
        return "Ringing...";
      case CallState.connectingToCall:
        return "Joining call...";
      case CallState.connected:
        return "Connected";
      case CallState.ended:
        return "Call ended";
      case CallState.cancelled:
        return "Call cancelled";
      case CallState.busy:
        return "User is busy";
      case CallState.noAnswer:
        return "No answer";
    }
  }
}

