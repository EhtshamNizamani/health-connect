import 'package:flutter/material.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/chat/presentation/screens/call_screen.dart';

class CallingScreen extends StatefulWidget {
  final String callID;
  final UserEntity currentUser;
  final DoctorEntity doctor;
  final UserEntity patient;

  const CallingScreen({
    super.key, 
    required this.callID,
    required this.currentUser,
    required this.doctor,
    required this.patient,
  });

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  bool _hasNavigatedToCall = false;

  @override
  void initState() {
    super.initState();
    // Automatically join the call after a short delay
    // This simulates the "dialing" experience
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_hasNavigatedToCall) {
        _joinCall();
      }
    });
  }

  void _joinCall() {
    if (_hasNavigatedToCall) return;
    _hasNavigatedToCall = true;

    // Determine who is the "other user" (the person being called)
    final otherUser = widget.currentUser.role == 'patient' 
        ? UserEntity(
            id: widget.doctor.uid,
            name: widget.doctor.name,
            photoUrl: widget.doctor.photoUrl,
            email: widget.doctor.email,
            role: 'doctor',
          )
        : widget.patient;

    // Navigate to CallScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callID: widget.callID,
          currentUser: widget.currentUser,
          otherUser: otherUser,
        ),
      ),
    );
  }

  void _cancelCall() {
    // TODO: Send a "call_cancelled" notification to the receiver
    // You can implement this similar to acceptCall function
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Determine the person being called
    final personBeingCalled = widget.currentUser.role == 'patient' 
        ? widget.doctor.name 
        : widget.patient.name;
    
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section with calling info
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Calling...", 
                    style: TextStyle(
                      fontSize: 24, 
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    personBeingCalled, 
                    style: const TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Avatar placeholder
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person, 
                      size: 70, 
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Connecting...",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom section with cancel button
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'cancel_call',
                    onPressed: _cancelCall,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}