
import 'package:flutter/material.dart';

class IncomingCallNameText extends StatelessWidget {
  final String name;
  
  const IncomingCallNameText({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}

// Role Chip Widget
class IncomingCallRoleChip extends StatelessWidget {
  final String role;
  
  const IncomingCallRoleChip({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
