import 'package:flutter/material.dart';

class IncomingCallAvatar extends StatelessWidget {
  final String photoUrl;
  
  const IncomingCallAvatar({
    super.key,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.5),
            Colors.purple.withOpacity(0.5),
            Colors.pink.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: CircleAvatar(
          radius: 87,
          backgroundColor: Colors.grey.shade800,
          backgroundImage: photoUrl.isNotEmpty
              ? NetworkImage(photoUrl)
              : null,
          child: photoUrl.isEmpty
              ? const Icon(
                  Icons.person,
                  size: 90,
                  color: Colors.white70,
                )
              : null,
        ),
      ),
    );
  }
}
