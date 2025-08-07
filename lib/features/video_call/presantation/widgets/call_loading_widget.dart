import 'package:flutter/material.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';

class CallLoadingWidget extends StatelessWidget {
  final UserEntity otherUser;
  final String status;

  const CallLoadingWidget({
    Key? key,
    required this.otherUser,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade800,
              backgroundImage: otherUser.photoUrl?.isNotEmpty == true
                  ? NetworkImage(otherUser.photoUrl!)
                  : null,
              child: otherUser.photoUrl?.isEmpty != false
                  ? const Icon(Icons.person, size: 60, color: Colors.white54)
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              otherUser.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              status,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
