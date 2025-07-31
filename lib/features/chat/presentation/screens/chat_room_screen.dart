import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_event.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_state.dart';
import 'package:health_connect/features/chat/presentation/screens/calling_screen.dart';
import 'package:health_connect/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:health_connect/features/chat/presentation/widgets/message_bubble.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/video_call/presantation/bloc/video_call_bloc.dart';
import 'package:health_connect/features/video_call/presantation/bloc/video_call_event.dart';
import 'package:health_connect/features/video_call/presantation/bloc/video_call_state.dart';

class ChatRoomScreen extends StatelessWidget {
  final String chatRoomId;
  final String chatPartnerName;
  final String receiverId;
  final UserEntity patient; // <<<--- NEW
  final DoctorEntity doctor; // <<<--- NEW

  const ChatRoomScreen({
    super.key,
    required this.chatRoomId,
    required this.chatPartnerName,
    required this.receiverId,
    required this.patient, // <<<--- NEW
    required this.doctor, // <<<--- NEW
  });

  @override
  Widget build(BuildContext context) {
    String currentUserId = '';
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedPatient) {
      currentUserId = authState.user.id;
    } else if (authState is AuthenticatedDoctorProfileExists) {
      currentUserId = authState.user.id;
    } else if (authState is AuthenticatedDoctorProfileNotExists) {
      currentUserId = authState.user.id;
    }
    return BlocProvider(
      create: (context) => sl<ChatRoomBloc>()
        ..add(
          SubscribeToMessages(chatRoomId),
        ), // Subscribe to messages as soon as the BLoC is created
      child: Scaffold(
        appBar: AppBar(
          title: Text(chatPartnerName),
          actions: [
            BlocBuilder<VideoCallBloc, VideoCallState>(
              builder: (context, state) {
                if (state is VideoCallInitiating) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.videocam_outlined),
                  onPressed: () {

                    final state = context.read<AuthBloc>().state;
                    UserEntity currentUser = UserEntity.empty();
                    if (state is AuthenticatedPatient) {
                      currentUser = state.user;
                    }
                    if (currentUser.id.isNotEmpty) {

                      context.read<VideoCallBloc>().add(
                        StartCall(
                          receiverId: receiverId,
                          callerName: currentUser.name,
                          callId: chatRoomId,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
        body: BlocListener<VideoCallBloc, VideoCallState>(
          listener: (context, state) {
            if (state is VideoCallInitiatedSuccess) {
              // Get user entities to pass to CallingScreen
              final state = context.read<AuthBloc>().state;
              UserEntity currentUser = UserEntity.empty();
              if (state is AuthenticatedPatient) {
                currentUser = state.user;
              }
              if (currentUser.id.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CallingScreen(
                      callID: chatRoomId,
                      currentUser: currentUser,
                      // Pass the doctor and patient entities here
                      doctor: doctor,
                      patient: patient,
                    ),
                  ),
                );
              }
            }
            if (state is VideoCallFailure) {
              // context.showSnackBar(message: state.message, type: SnackBarType.error);
            }
          },

          child: Column(
            children: [
              // --- Message List ---
              Expanded(
                child: BlocBuilder<ChatRoomBloc, ChatRoomState>(
                  builder: (context, state) {
                    if (state is ChatRoomLoading || state is ChatRoomInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ChatRoomError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is ChatRoomLoaded) {
                      if (state.messages.isEmpty) {
                        return const Center(
                          child: Text("No messages yet. Say hello!"),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        reverse: true, // This is key for chat UIs
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          final bool isMe = message.senderId == currentUserId;
                          return MessageBubble(
                            key: ValueKey(message.id),
                            message: message,
                            isMe: isMe,
                          );
                        },
                      );
                    }
                    // This will catch other states like MessageSending etc.
                    // Or you can handle them explicitly. For now, we show the loaded messages.
                    if (state is ChatRoomLoaded) {
                      return const Center(child: Text("Something went wrong"));
                    }
                    // Fallback
                    return const SizedBox.shrink();
                  },
                ),
              ),
              // --- Chat Input Field ---
              // Pass the necessary IDs to the input field
              ChatInputField(
                chatRoomId: chatRoomId,
                receiverId: receiverId,
                doctor: doctor,
                patient: patient,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
