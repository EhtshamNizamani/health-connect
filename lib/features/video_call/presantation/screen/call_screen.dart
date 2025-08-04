import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_event.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_state.dart';
import 'package:health_connect/features/video_call/presantation/widgets/call_content_widget.dart';
import 'package:health_connect/features/video_call/presantation/widgets/call_error_widget.dart';
import 'package:health_connect/features/video_call/presantation/widgets/call_loading_widget.dart';

class CallScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CallScreenBloc>(),
      child: CallScreenView(
        // Pass the parameters to the child
        callID: callID,
        currentUser: currentUser,
        otherUser: otherUser,
      ),
    );
  }
}

class CallScreenView extends StatefulWidget {
  final String callID;
  final UserEntity currentUser;
  final UserEntity otherUser;

  const CallScreenView({
    super.key,
    required this.callID,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<CallScreenView> createState() => _CallScreenViewState();
}

class _CallScreenViewState extends State<CallScreenView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<CallScreenBloc, CallScreenState>(
        listener: (context, state) {
          if (state is CallScreenEnded) {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          }
          // No need for error snackbar here if the CallErrorWidget handles it
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
              onExit: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
