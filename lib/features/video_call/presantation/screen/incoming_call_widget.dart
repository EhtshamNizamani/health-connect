import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/video_call/presantation/screen/call_screen.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final String callerName;
  final String callerId;
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

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isAnswering = false;
  bool _isDeclining = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startRingtone();
    
    // Add haptic feedback for incoming call
    HapticFeedback.heavyImpact();
    
    // Set system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    FlutterRingtonePlayer().stop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _initializeAnimations() {
    // Pulse animation for avatar
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Slide animation for buttons
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  void _startRingtone() {
    try {
      FlutterRingtonePlayer().playRingtone();
    } catch (e) {
      print("Failed to play ringtone: $e");
    }
  }

  void _onAcceptCall(BuildContext context) async {
    if (_isAnswering) return;
    
    setState(() {
      _isAnswering = true;
    });

    // Stop ringtone and add haptic feedback
    FlutterRingtonePlayer().stop();
    HapticFeedback.mediumImpact();

    final authState = context.read<AuthBloc>().state;
    final UserEntity? currentUser = authState.user;
    if (currentUser == null) { 
      Navigator.of(context).pop();
      return; 
    }

    try {
      print("Sending 'acceptCall' signal to caller: ${widget.callerId}");
      final HttpsCallable callable = FirebaseFunctions
          .instanceFor(region: "europe-west1")
          .httpsCallable('acceptCall');
      
      await callable.call<void>({
        'callerId': widget.callerId,
        'callId': widget.callId,
      });
      print("'acceptCall' signal sent successfully.");
    } catch (e) {
      print("Failed to send 'acceptCall' signal: $e");
    }

    final otherUser = UserEntity(
      id: widget.callerId,
      name: widget.callerName,
      photoUrl: widget.callerPhotoUrl,
      email: '',
      role: widget.callerRole,
    );

    // Navigate to CallScreen with animation
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CallScreen(
          callID: widget.callId,
          currentUser: currentUser,
          otherUser: otherUser,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _onDeclineCall() async {
    if (_isDeclining) return;
    
    setState(() {
      _isDeclining = true;
    });

    // Stop ringtone and add haptic feedback
    FlutterRingtonePlayer().stop();
    HapticFeedback.mediumImpact();

    try {
      // Send decline notification
      final HttpsCallable callable = FirebaseFunctions
          .instanceFor(region: "europe-west1")
          .httpsCallable('declineCall');
      
      await callable.call<void>({
        'callerId': widget.callerId,
        'callId': widget.callId,
      });
      print("'declineCall' signal sent successfully.");
    } catch (e) {
      print("Failed to send 'declineCall' signal: $e");
    }

    // Animate out and close
    await _slideController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.purple.withOpacity(0.2),
                  Colors.black,
                ],
              ),
            ),
          ),
          
          // Animated particles background
          ...List.generate(20, (index) => _buildFloatingParticle(size)),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top section
                _buildTopSection(),
                
                // Main content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile section
                      _buildProfileSection(),
                      
                      const SizedBox(height: 60),
                      
                      // Incoming call text with animation
                      _buildIncomingCallText(),
                    ],
                  ),
                ),
                
                // Bottom controls
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildBottomControls(),
                ),
              ],
            ),
          ),
          
          // Loading overlay when answering/declining
          if (_isAnswering || _isDeclining)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(Size size) {
    return Positioned(
      left: (size.width * (0.1 + (0.8 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000))),
      top: (size.height * (0.1 + (0.8 * (DateTime.now().microsecondsSinceEpoch % 1000) / 1000))),
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

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  "Video Call",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        // Animated avatar
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
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
                    backgroundImage: widget.callerPhotoUrl.isNotEmpty
                        ? NetworkImage(widget.callerPhotoUrl)
                        : null,
                    child: widget.callerPhotoUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 90,
                            color: Colors.white70,
                          )
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 30),
        
        // Caller name
        Text(
          widget.callerName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Caller role
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.callerRole.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomingCallText() {
    return Column(
      children: [
        Text(
          "Incoming Video Call",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple, Colors.pink],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Decline button
          _buildActionButton(
            icon: Icons.call_end,
            color: Colors.red,
            size: 70,
            onTap: _onDeclineCall,
            isLoading: _isDeclining,
          ),
          
          // Message button (optional)
          _buildSecondaryActionButton(
            icon: Icons.message,
            onTap: () {
              // TODO: Send quick message
            },
          ),
          
          // Accept button
          _buildActionButton(
            icon: Icons.videocam,
            color: Colors.green,
            size: 70,
            onTap: () => _onAcceptCall(context),
            isLoading: _isAnswering,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Icon(
                icon,
                color: Colors.white,
                size: size * 0.45,
              ),
      ),
    );
  }

  Widget _buildSecondaryActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              _isAnswering ? "Connecting..." : "Ending call...",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}