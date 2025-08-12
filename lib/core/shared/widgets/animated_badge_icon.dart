import 'package:flutter/material.dart';

class AnimatedBadgeIcon extends StatefulWidget {
  final Widget child;
  // triggerKey ko int banayein taaki type safety rahe
  final int triggerKey;

  const AnimatedBadgeIcon({
    super.key,
    required this.child,
    required this.triggerKey,
  });

  @override
  State<AnimatedBadgeIcon> createState() => _AnimatedBadgeIconState();
}

class _AnimatedBadgeIconState extends State<AnimatedBadgeIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // Animation ko thoda fast karein
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Animation ko aesa banayein ki woh aage jaaye aur phir wapas aaye
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).chain(CurveTween(curve: Curves.easeOut)).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant AnimatedBadgeIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animation tabhi trigger karein jab count badhe,
    // kam hone par nahi (e.g., jab user read kare).
    if (widget.triggerKey > oldWidget.triggerKey) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}