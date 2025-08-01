import 'package:flutter/material.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';

class CallVideoWidget extends StatelessWidget {
  final Widget? localView;
  final Widget? remoteView;
  final UserEntity otherUser;
  final String connectionStatus;

  const CallVideoWidget({
    Key? key,
    this.localView,
    this.remoteView,
    required this.otherUser,
    required this.connectionStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main video view (remote or local if no remote)
        _buildMainVideoView(),

        // Picture-in-picture local view
        if (remoteView != null && localView != null)
          _buildPictureInPictureView(),
      ],
    );
  }

  Widget _buildMainVideoView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: remoteView ?? localView ?? _buildWaitingView(),
    );
  }

  Widget _buildWaitingView() {
    return Center(
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
            connectionStatus,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPictureInPictureView() {
    return Positioned(
      top: 100,
      right: 16,
      child: Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: localView ??
              Container(
                color: Colors.grey.shade800,
                child: const Icon(
                  Icons.person,
                  color: Colors.white54,
                  size: 40,
                ),
              ),
        ),
      ),
    );
  }
}

