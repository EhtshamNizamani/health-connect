// features/video_call/presentation/widgets/calling_content_widget.dart (NEW FILE)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/video_call/domain/entity/calling_entity.dart';
import 'package:health_connect/features/video_call/domain/entity/video_call_enitity.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/vide_call_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/vide_call_event.dart';
import 'package:health_connect/features/video_call/presantation/widgets/calling_avtar_widget.dart';
import 'package:health_connect/features/video_call/presantation/widgets/calling_controll_widget.dart';
import 'package:health_connect/features/video_call/presantation/widgets/calling_ring_animation.dart';
import 'package:health_connect/features/video_call/presantation/widgets/calling_status_widget.dart';
import 'package:health_connect/features/video_call/presantation/widgets/calling_top_section_widget.dart';

class CallingContentWidget extends StatefulWidget {
  final VideoCallEntity callingEntity;
  final bool shouldStartAnimations;

  const CallingContentWidget({
    Key? key,
    required this.callingEntity,
    required this.shouldStartAnimations,
  }) : super(key: key);

  @override
  State<CallingContentWidget> createState() => _CallingContentWidgetState();
}

class _CallingContentWidgetState extends State<CallingContentWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _ringController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (widget.shouldStartAnimations) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(CallingContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleStateChanges(oldWidget.callingEntity.status);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
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
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
  }

  void _handleStateChanges(VideoCallStatus previousState) {
    final currentState = widget.callingEntity.status;
    
    if (currentState != previousState) {
      switch (currentState) {
        case VideoCallStatus.connecting:
          _pulseController.repeat(reverse: true);
          _ringController.stop();
          break;
        case VideoCallStatus.ringing:
          _pulseController.repeat(reverse: true);
          _ringController.repeat();
          break;
        case VideoCallStatus.connectingToCall:
          _pulseController.stop();
          _ringController.stop();
          break;
        case VideoCallStatus.cancelled:
        case VideoCallStatus.ended:
          _pulseController.stop();
          _ringController.stop();
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top section with status
          CallingTopSectionWidget(
            callState: widget.callingEntity.status,
          ),

          // Main content area
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile picture with animation
                CallingAvatarWidget(
                  photoUrl: widget.callingEntity.receiverPhotoUrl,
                  pulseAnimation: _pulseAnimation,
                  callState: widget.callingEntity.status,
                ),

                const SizedBox(height: 40),

                // Person name
                Text(
                  widget.callingEntity.receiverName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Call status
                CallingStatusWidget(
                  callState: widget.callingEntity.status,
                ),

                const SizedBox(height: 60),

                // Ring animation (only during ringing)
                if (widget.callingEntity.status == VideoCallStatus.ringing)
                  CallingRingAnimationWidget(
                    ringAnimation: _ringAnimation,
                  ),
              ],
            ),
          ),

          // Bottom controls
          CallingControlsWidget(
            callState: widget.callingEntity.status,
            onCancel: () {
              context.read<VideoCallBloc>().add(DeclineCall(callerId: '', callId: ''));
            },
          ),
        ],
      ),
    );
  }
}