import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/video_call/presantation/screen/call_screen.dart';

enum CallState { 
  connecting, 
  ringing, 
  connecting_to_call, 
  connected, 
  ended, 
  busy,
  no_answer,
  cancelled 
}

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

class _CallingScreenState extends State<CallingScreen> 
    with TickerProviderStateMixin {
  
  CallState _callState = CallState.connecting;
  bool _hasNavigatedToCall = false;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _ringController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _ringAnimation;
  
  // Timer for call timeout
  int _callDurationSeconds = 0;
  bool _isCallTimerActive = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCallingSequence();
    
    // Add haptic feedback
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // Pulse animation for avatar
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Ring animation for calling effect
    _ringController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _ringAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  void _startCallingSequence() async {
    // Step 1: Connecting
    setState(() => _callState = CallState.connecting);
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    // Step 2: Ringing
    setState(() => _callState = CallState.ringing);
    _ringController.repeat();
    
    // Auto-connect after showing ringing for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted || _hasNavigatedToCall) return;
    
    // Step 3: Connecting to call
    setState(() => _callState = CallState.connecting_to_call);
    _ringController.stop();
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted || _hasNavigatedToCall) return;
    
    // Step 4: Join the actual call
    _joinCall();
  }

  void _joinCall() {
    if (_hasNavigatedToCall) return;
    _hasNavigatedToCall = true;

    // Determine who is the "other user"
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

  void _cancelCall() async {
    if (_hasNavigatedToCall) return;
    
    setState(() => _callState = CallState.cancelled);
    _pulseController.stop();
    _ringController.stop();
    
    // Add haptic feedback
    HapticFeedback.mediumImpact();
    
    // TODO: Send call cancelled notification
    try {
      final receiverId = widget.currentUser.role == 'patient' 
          ? widget.doctor.uid 
          : widget.patient.id;
          
      final HttpsCallable callable = FirebaseFunctions
          .instanceFor(region: "europe-west1")
          .httpsCallable('cancelCall');
      
      await callable.call<void>({
        'receiverId': receiverId,
        'callId': widget.callID,
      });
    } catch (e) {
      print("Failed to send cancel notification: $e");
    }
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final personBeingCalled = widget.currentUser.role == 'patient' 
        ? widget.doctor.name 
        : widget.patient.name;
    
    final personPhotoUrl = widget.currentUser.role == 'patient' 
        ? widget.doctor.photoUrl 
        : widget.patient.photoUrl;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a), // Dark professional background
      body: SafeArea(
        child: Column(
          children: [
            // Top section with status
            _buildTopSection(),
            
            // Main content area
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile picture with animation
                  _buildAnimatedAvatar(personPhotoUrl),
                  
                  const SizedBox(height: 40),
                  
                  // Person name
                  Text(
                    personBeingCalled,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Call status
                  _buildCallStatus(),
                  
                  const SizedBox(height: 60),
                  
                  // Ring animation (only during ringing)
                  if (_callState == CallState.ringing)
                    _buildRingAnimation(),
                ],
              ),
            ),
            
            // Bottom controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getCallStateText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Video call icon
          const Icon(
            Icons.videocam,
            color: Colors.white70,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAvatar(String? photoUrl) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _callState == CallState.ringing ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.purple.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 76,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null || photoUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white70,
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallStatus() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _getCallStatusMessage(),
        key: ValueKey(_callState),
        style: TextStyle(
          fontSize: 18,
          color: Colors.white.withOpacity(0.8),
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRingAnimation() {
    return AnimatedBuilder(
      animation: _ringAnimation,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(_ringAnimation.value),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Row(
        mainAxisAlignment: _callState == CallState.connecting || 
                          _callState == CallState.connecting_to_call
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceEvenly,
        children: [
          // Cancel/End call button
          GestureDetector(
            onTap: _cancelCall,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red,
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          
          // Additional controls can be added here if needed
          // For now, we keep it simple like WhatsApp
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_callState) {
      case CallState.connecting:
        return Colors.orange;
      case CallState.ringing:
        return Colors.blue;
      case CallState.connecting_to_call:
        return Colors.green;
      case CallState.connected:
        return Colors.green;
      case CallState.ended:
      case CallState.cancelled:
        return Colors.red;
      case CallState.busy:
      case CallState.no_answer:
        return Colors.red;
    }
  }

  String _getCallStateText() {
    switch (_callState) {
      case CallState.connecting:
        return "Connecting";
      case CallState.ringing:
        return "Ringing";
      case CallState.connecting_to_call:
        return "Joining";
      case CallState.connected:
        return "Connected";
      case CallState.ended:
        return "Call Ended";
      case CallState.cancelled:
        return "Cancelled";
      case CallState.busy:
        return "Busy";
      case CallState.no_answer:
        return "No Answer";
    }
  }

  String _getCallStatusMessage() {
    switch (_callState) {
      case CallState.connecting:
        return "Connecting...";
      case CallState.ringing:
        return "Ringing...";
      case CallState.connecting_to_call:
        return "Joining call...";
      case CallState.connected:
        return "Connected";
      case CallState.ended:
        return "Call ended";
      case CallState.cancelled:
        return "Call cancelled";
      case CallState.busy:
        return "User is busy";
      case CallState.no_answer:
        return "No answer";
    }
  }
}