import 'package:flutter/material.dart';
import 'package:health_connect/features/video_call/domain/entity/video_call_enitity.dart';

class CallingTopSectionWidget extends StatelessWidget {
  final VideoCallStatus callState;

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
      case VideoCallStatus.connecting:
        return Colors.orange;
      case VideoCallStatus.ringing:
        return Colors.blue;
      case VideoCallStatus.connectingToCall:
        return Colors.green;
      case VideoCallStatus.connected:
        return Colors.green;
      case VideoCallStatus.ended:
      case VideoCallStatus.cancelled:
        return Colors.red;
      case VideoCallStatus.busy:
      case VideoCallStatus.noAnswer:
        return Colors.red;
      case VideoCallStatus.initiating:
        return Colors.blue;
      case VideoCallStatus.failed:
        return Colors.red;
    }
  }

  String _getCallStateText() {
    switch (callState) {
      case VideoCallStatus.connecting:
        return "Connecting";
      case VideoCallStatus.ringing:
        return "Ringing";
      case VideoCallStatus.connectingToCall:
        return "Joining";
      case VideoCallStatus.connected:
        return "Connected";
      case VideoCallStatus.ended:
        return "Call Ended";
      case VideoCallStatus.cancelled:
        return "Cancelled";
      case VideoCallStatus.busy:
        return "Busy";
      case VideoCallStatus.noAnswer:
        return "No Answer";
      case VideoCallStatus.initiating:
        return "Initiating";
      case VideoCallStatus.failed:
        return "Failed Dalled";
    }
  }
}