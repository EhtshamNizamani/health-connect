
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/video_call/presantation/blocs/calling/calling_screen_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/calling/calling_screen_event.dart';
import 'package:health_connect/features/video_call/presantation/blocs/calling/calling_screen_state.dart';
import 'package:health_connect/features/video_call/presantation/screen/call_screen.dart';
import 'package:health_connect/features/video_call/presantation/widgets/calling_content_widget.dart';
import 'package:health_connect/features/video_call/presantation/widgets/calling_error_widget.dart';
import 'package:health_connect/features/video_call/presantation/widgets/calling_loading_widget.dart';

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
  @override
  void initState() {
    super.initState();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CallingScreenBloc>()..add(
        InitializeCalling(
          callId: widget.callID,
          currentUser: widget.currentUser,
          doctor: widget.doctor,
          patient: widget.patient,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1a1a1a),
        body: BlocConsumer<CallingScreenBloc, CallingScreenState>(
          listener: (context, state) {
            if (state is CallingScreenCancelled) {
              Navigator.pop(context);
            }
            
            if (state is CallingScreenNavigateToCall) {
              final otherUser = UserEntity(
                id: state.otherUserId,
                name: state.otherUserName,
                photoUrl: state.otherUserPhotoUrl,
                email: '', // Will be filled from existing data
                role: widget.currentUser.role == 'patient' ? 'doctor' : 'patient',
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CallScreen(
                    callID: state.callId,
                    currentUser: widget.currentUser,
                    otherUser: otherUser,
                  ),
                ),
              );
            }
            
            if (state is CallingScreenError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CallingScreenInitial || state is CallingScreenLoading) {
              return const CallingLoadingWidget();
            }
            
            if (state is CallingScreenActive) {
              return CallingContentWidget(
                callingEntity: state.callingEntity,
                shouldStartAnimations: state.shouldStartAnimations,
              );
            }
            
            if (state is CallingScreenError) {
              return CallingErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<CallingScreenBloc>().add(
                    InitializeCalling(
                      callId: widget.callID,
                      currentUser: widget.currentUser,
                      doctor: widget.doctor,
                      patient: widget.patient,
                    ),
                  );
                },
                onCancel: () => Navigator.pop(context),
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}