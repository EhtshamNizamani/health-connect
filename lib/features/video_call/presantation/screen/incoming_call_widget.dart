import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/vide_call_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/vide_call_event.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/vide_call_state.dart';
import 'package:health_connect/features/video_call/presantation/screen/call_screen.dart';
import 'package:health_connect/features/video_call/presantation/widgets/incoming_call_controls.dart';
import 'package:health_connect/features/video_call/presantation/widgets/incoming_call_loading.dart';
import 'package:health_connect/features/video_call/presantation/widgets/incoming_call_particles.dart';
import 'package:health_connect/features/video_call/presantation/widgets/incoming_call_profile.dart';
import 'package:health_connect/features/video_call/presantation/widgets/incoming_call_text.dart';
import 'package:health_connect/features/video_call/presantation/widgets/incomming_call_bg.dart';
import 'package:health_connect/features/video_call/presantation/widgets/incomming_call_top_section.dart';

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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Slide animation for buttons
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

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
    // Stop ringtone and add haptic feedback
    FlutterRingtonePlayer().stop();
    HapticFeedback.mediumImpact();

    final authState = context.read<AuthBloc>().state;
    final UserEntity? currentUser = authState.user;
    if (currentUser == null) {
      Navigator.of(context).pop();
      return;
    }

    // Use VideoCallBloc to handle accept call
    context.read<VideoCallBloc>().add(
      AcceptCall(callerId: widget.callerId, callId: widget.callId),
    );

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
    // Stop ringtone and add haptic feedback
    FlutterRingtonePlayer().stop();
    HapticFeedback.mediumImpact();
    // Use VideoCallBloc to handle decline call
    context.read<VideoCallBloc>().add(
      DeclineCall(callerId: widget.callerId, callId: widget.callId),
    );

    // Animate out and close
    await _slideController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<VideoCallBloc, VideoCallState>(
      listener: (context, state) {
        if (state is VideoCallFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Call error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0a0a0a),
        body: Stack(
          children: [
            // Gradient background
            const IncomingCallBackground(),

            // Animated particles background
            IncomingCallParticles(size: size),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top section
                  const IncomingCallTopSection(),

                  // Main content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Profile section
                        IncomingCallProfile(
                          callerName: widget.callerName,
                          callerRole: widget.callerRole,
                          callerPhotoUrl: widget.callerPhotoUrl,
                          pulseAnimation: _pulseAnimation,
                        ),

                        const SizedBox(height: 60),

                        // Incoming call text with animation
                        const IncomingCallText(),
                      ],
                    ),
                  ),

                  // Bottom controls
                  SlideTransition(
                    position: _slideAnimation,
                    child: IncomingCallControls(
                      onAccept: () => _onAcceptCall(context),
                      onDecline: _onDeclineCall,
                      onMessage: () {
                        // TODO: Send quick message
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Loading overlay when processing
            BlocBuilder<VideoCallBloc, VideoCallState>(
              builder: (context, state) {
                print("Thi si my state $state");

                if (state is VideoCallCancelled) {
                  FlutterRingtonePlayer().stop();
                  HapticFeedback.mediumImpact();
                  // Animate out and close
                  _slideController.reverse();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
                if (state is VideoCallInitiating) {
                  return const IncomingCallLoadingOverlay(
                    message: "Connecting...",
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
