import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CallControlsWidget extends StatelessWidget {
  final bool isCameraEnabled;
  final bool isMicEnabled;
  final bool isSpeakerEnabled;
  final Function(bool) onCameraToggle;
  final Function(bool) onMicToggle;
  final Function(bool) onSpeakerToggle;
  final VoidCallback onSwitchCamera;
  final VoidCallback onEndCall;

  const CallControlsWidget({
    Key? key,
    required this.isCameraEnabled,
    required this.isMicEnabled,
    required this.isSpeakerEnabled,
    required this.onCameraToggle,
    required this.onMicToggle,
    required this.onSpeakerToggle,
    required this.onSwitchCamera,
    required this.onEndCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 50, left: 20, right: 20, top: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Speaker toggle
            _buildControlButton(
              icon: isSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
              isActive: isSpeakerEnabled,
              onTap: () => onSpeakerToggle(!isSpeakerEnabled),
            ),

            // Microphone toggle
            _buildControlButton(
              icon: isMicEnabled ? Icons.mic : Icons.mic_off,
              isActive: isMicEnabled,
              onTap: () => onMicToggle(!isMicEnabled),
            ),

            // End call button
            _buildControlButton(
              icon: Icons.call_end,
              isActive: false,
              isEndCall: true,
              onTap: onEndCall,
            ),

            // Camera toggle
            _buildControlButton(
              icon: isCameraEnabled ? Icons.videocam : Icons.videocam_off,
              isActive: isCameraEnabled,
              onTap: () => onCameraToggle(!isCameraEnabled),
            ),

            // Switch camera
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              isActive: false,
              onTap: onSwitchCamera,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isEndCall = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isEndCall
              ? Colors.red
              : isActive
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: isEndCall
                ? Colors.red
                : isActive
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isEndCall
                  ? Colors.red.withOpacity(0.4)
                  : Colors.black.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
