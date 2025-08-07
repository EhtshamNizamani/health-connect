import 'package:flutter/material.dart';
import 'package:health_connect/features/video_call/domain/entity/video_call_enitity.dart';

class CallingAvatarWidget extends StatelessWidget {
  final String? photoUrl;
  final Animation<double> pulseAnimation;
  final VideoCallStatus callState;

  const CallingAvatarWidget({
    Key? key,
    this.photoUrl,
    required this.pulseAnimation,
    required this.callState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: callState == VideoCallStatus.ringing ? pulseAnimation.value : 1.0,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.purple.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 76,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                    ? NetworkImage(photoUrl!)
                    : null,
                child: photoUrl == null || photoUrl!.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white70,
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
