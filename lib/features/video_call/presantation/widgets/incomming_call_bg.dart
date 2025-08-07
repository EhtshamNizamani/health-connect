
// Background Widget
import 'package:flutter/material.dart';

class IncomingCallBackground extends StatelessWidget {
  const IncomingCallBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.2,
          colors: [
            Colors.blue.withOpacity(0.3),
            Colors.purple.withOpacity(0.2),
            Colors.black,
          ],
        ),
      ),
    );
  }
}