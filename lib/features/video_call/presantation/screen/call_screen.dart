import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_event.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_state.dart';
import 'package:health_connect/features/video_call/presantation/widgets/cal_content_widget.dart';
import 'package:health_connect/features/video_call/presantation/widgets/call_error_widget.dart';
import 'package:health_connect/features/video_call/presantation/widgets/call_loading_widget.dart';

class CallScreen extends StatefulWidget {
  final String callID;
  final UserEntity currentUser;
  final UserEntity otherUser;

  const CallScreen({
    super.key,
    required this.callID,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    // Initialize call
    context.read<CallScreenBloc>().add(
      InitializeCall(
        widget.callID,
        widget.currentUser.id,
        widget.currentUser.name,
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CallScreenBloc>(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocConsumer<CallScreenBloc, CallScreenState>(
          listener: (context, state) {
            if (state is CallScreenEnded) {
              Navigator.of(context).pop();
            }
            if (state is CallScreenError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CallScreenLoading || state is CallScreenInitial) {
              return CallLoadingWidget(
                otherUser: widget.otherUser,
                status: "Initializing call...",
              );
            }
            
            if (state is CallScreenConnecting) {
              return CallLoadingWidget(
                otherUser: widget.otherUser,
                status: "Connecting...",
              );
            }
            
            if (state is CallScreenConnected) {
              return CallContentWidget(
                state: state,
                currentUser: widget.currentUser,
                otherUser: widget.otherUser,
                callId: widget.callID,
              );
            }
            
            if (state is CallScreenError) {
              return CallErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<CallScreenBloc>().add(
                    InitializeCall(
                      widget.callID,
                      widget.currentUser.id,
                      widget.currentUser.name,
                    ),
                  );
                },
                onExit: () => Navigator.of(context).pop(),
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}