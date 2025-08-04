import 'package:flutter/material.dart';

class IncomingCallParticles extends StatelessWidget {
  final Size size;
  
  const IncomingCallParticles({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(20, (index) => FloatingParticle(
        size: size,
        index: index,
      )),
    );
  }
}

class FloatingParticle extends StatelessWidget {
  final Size size;
  final int index;
  
  const FloatingParticle({
    super.key,
    required this.size,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (size.width * (0.1 + (0.8 * ((DateTime.now().millisecondsSinceEpoch + index * 100) % 1000) / 1000))),
      top: (size.height * (0.1 + (0.8 * ((DateTime.now().microsecondsSinceEpoch + index * 150) % 1000) / 1000))),
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
