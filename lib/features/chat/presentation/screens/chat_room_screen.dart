import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_event.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_state.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/video_call_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/video_call_event.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/video_call_state.dart';
import 'package:health_connect/features/video_call/presantation/screen/calling_screen.dart';
import 'package:health_connect/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:health_connect/features/chat/presentation/widgets/message_bubble.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

class ChatRoomScreen extends StatelessWidget {
  final String chatRoomId;
  final String chatPartnerName;
  final String receiverId;
  final UserEntity patient;
  final DoctorEntity doctor;

  const ChatRoomScreen({
    super.key,
    required this.chatRoomId,
    required this.chatPartnerName,
    required this.receiverId,
    required this.patient,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    // We provide both BLoCs at the top of the screen
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<ChatRoomBloc>()..add(SubscribeToMessages(chatRoomId)),
        ),
        BlocProvider(
          create: (context) => sl<VideoCallBloc>(), // The INVITATION BLoC
        ),
      ],
      // Use a Builder to get a context that is below the providers
      child: Builder(
        builder: (context) {
          // --- GET CURRENT USER ID SAFELY ---
          final authState = context.read<AuthBloc>().state;
          final currentUserId = authState.user?.id ?? '';

          return Scaffold(
            appBar: AppBar(
              title: Text(chatPartnerName),
              actions: [
                // --- THE CALL BUTTON ---
                // This builder listens to the INVITATION BLoC
                BlocBuilder<VideoCallBloc, VideoCallState>(
                  builder: (context, state) {
                    // Show a loader when the invitation is being sent
                    if (state is VideoCallInitiating) {
                      return const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    }
                    return IconButton(
                      icon: const Icon(Icons.videocam_outlined),
                      onPressed: () {
                        final currentUser = context.read<AuthBloc>().state.user;
                        if (currentUser != null) {
                          print("Dispatching StartCall event...");
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
            // --- THE LISTENER FOR NAVIGATION ---
            // This listener also listens to the INVITATION BLoC
            body: BlocListener<VideoCallBloc, VideoCallState>(
              listener: (context, state) {
                print("VideoCallBloc Listener received state: $state");
                // When the invitation is successfully sent, navigate to the CallingScreen
                if (state is VideoCallInitiatedSuccess) {
                  final currentUser = context.read<AuthBloc>().state.user;
                  if (currentUser!=null) {
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
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
                            return const Center(child: Text("No messages yet. Say hello!"));
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            reverse: true,
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
                        return const Center(child: Text("Something went wrong"));
                      },
                    ),
                  ),
                  // --- Chat Input Field ---
                  ChatInputField(
                    chatRoomId: chatRoomId,
                    receiverId: receiverId,
                    doctor: doctor,
                    patient: patient,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}