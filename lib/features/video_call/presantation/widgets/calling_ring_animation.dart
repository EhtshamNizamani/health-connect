import 'package:flutter/material.dart';

class CallingRingAnimationWidget extends StatelessWidget {
  final Animation<double> ringAnimation;

  const CallingRingAnimationWidget({
    Key? key,
    required this.ringAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ringAnimation,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(ringAnimation.value),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
