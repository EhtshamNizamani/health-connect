import 'package:flutter/material.dart';
import 'package:health_connect/features/video_call/domain/entity/calling_entity.dart';

class CallingTopSectionWidget extends StatelessWidget {
  final CallState callState;

  const CallingTopSectionWidget({
    Key? key,
    required this.callState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getCallStateText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Video call icon
          const Icon(
            Icons.videocam,
            color: Colors.white70,
            size: 24,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (callState) {
      case CallState.connecting:
        return Colors.orange;
      case CallState.ringing:
        return Colors.blue;
      case CallState.connectingToCall:
        return Colors.green;
      case CallState.connected:
        return Colors.green;
      case CallState.ended:
      case CallState.cancelled:
        return Colors.red;
      case CallState.busy:
      case CallState.noAnswer:
        return Colors.red;
    }
  }

  String _getCallStateText() {
    switch (callState) {
      case CallState.connecting:
        return "Connecting";
      case CallState.ringing:
        return "Ringing";
      case CallState.connectingToCall:
        return "Joining";
      case CallState.connected:
        return "Connected";
      case CallState.ended:
        return "Call Ended";
      case CallState.cancelled:
        return "Cancelled";
      case CallState.busy:
        return "Busy";
      case CallState.noAnswer:
        return "No Answer";
    }
  }
}