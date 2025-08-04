
import 'package:flutter/material.dart';
import 'package:health_connect/features/video_call/presantation/widgets/incoming_call_avtar.dart';
import 'package:health_connect/features/video_call/presantation/widgets/incoming_call_name_text.dart';

class IncomingCallProfile extends StatelessWidget {
  final String callerName;
  final String callerRole;
  final String callerPhotoUrl;
  final Animation<double> pulseAnimation;

  const IncomingCallProfile({
    super.key,
    required this.callerName,
    required this.callerRole,
    required this.callerPhotoUrl,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated avatar
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: pulseAnimation.value,
              child: IncomingCallAvatar(photoUrl: callerPhotoUrl),
            );
          },
        ),
        
        const SizedBox(height: 30),
        
        // Caller name
        IncomingCallNameText(name: callerName),
        
        const SizedBox(height: 8),
        
        // Caller role
        IncomingCallRoleChip(role: callerRole),
      ],
    );
  }
}
