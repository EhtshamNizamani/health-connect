import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/chat/presentation/screens/call_screen.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart'; // To read AuthBloc state
class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final String callerName;
  final String callerId;
  // --- NAYE FIELDS ---
  final String callerRole;
  final String callerPhotoUrl;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.callerName,
    required this.callerId,
    required this.callerRole,
    required this.callerPhotoUrl,
  });


  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  @override
  void initState() {
    super.initState();
    // Start playing the default ringtone when the screen appears
    FlutterRingtonePlayer().playRingtone();
  }

  @override
  void dispose() {
    // Stop the ringtone when the screen is closed (e.g., call accepted/declined)
    FlutterRingtonePlayer().stop();
    super.dispose();
  }void _onAcceptCall(BuildContext context) async {
  // Get the current user (the receiver)
  final authState = context.read<AuthBloc>().state;
  final UserEntity? currentUser = authState.user;
  if (currentUser == null) { return; }

  // Send the "accept" signal back to the caller with complete data
  try {
    print("Sending 'acceptCall' signal to caller: ${widget.callerId}");
    final HttpsCallable callable = FirebaseFunctions.instanceFor(region: "europe-west1").httpsCallable('acceptCall');
    await callable.call<void>({
      'callerId': widget.callerId,
      'callId': widget.callId,
    });
    print("'acceptCall' signal sent successfully.");
  } catch (e) {
    print("Failed to send 'acceptCall' signal: $e");
  }

  // Create otherUser entity
  final otherUser = UserEntity(
    id: widget.callerId,
    name: widget.callerName,
    photoUrl: widget.callerPhotoUrl,
    email: '',
    role: widget.callerRole,
  );

  // Navigate to CallScreen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => CallScreen(
        callID: widget.callId,
        currentUser: currentUser,
        otherUser: otherUser,
      ),
    ),
  );
}


  void _onDeclineCall() {
    // Just pop the screen to dismiss the call
    Navigator.of(context).pop();
    // TODO: Optionally, send a 'call_declined' notification back to the caller
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Use a dark background for a cinematic feel
      backgroundColor: theme.colorScheme.primary.withOpacity(0.9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- Caller Info (Top) ---
              Column(
                children: [
                  const SizedBox(height: 60),
                  Text(
                    "Incoming Call",
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.callerName,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.person, size: 70, color: Colors.white),
                    // TODO: Add caller's photo if you pass it in the notification
                  ),
                ],
              ),
              
              // --- Action Buttons (Bottom) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Decline Button
                  Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'decline_button',
                        onPressed: _onDeclineCall,
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.call_end, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text("Decline", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  // Accept Button
                  Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'accept_button',
                        onPressed: () => _onAcceptCall(context),
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.videocam, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text("Accept", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}