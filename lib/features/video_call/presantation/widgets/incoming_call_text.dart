import 'package:flutter/material.dart';

class IncomingCallText extends StatelessWidget {
  const IncomingCallText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Incoming Video Call",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple, Colors.pink],
            ),
          ),
        ),
      ],
    );
  }
}

