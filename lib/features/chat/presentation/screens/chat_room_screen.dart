import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_event.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_state.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_event.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/video_call_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/video_call_event.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/video_call_state.dart';
import 'package:health_connect/features/video_call/presantation/screen/calling_screen.dart';
import 'package:health_connect/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:health_connect/features/chat/presentation/widgets/message_bubble.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

class ChatRoomScreen extends StatefulWidget {
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
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen>
    with WidgetsBindingObserver {
  bool _isScreenVisible = true;
  final ScrollController _scrollController = ScrollController();
  
  // Naye messages ki ginti track karne ke liye variable
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Jab screen khule, messages ko read mark karein
    _markChatAsRead();
    // Initial messages ki ginti set karen.
    // Agar aap chatroom bloc se initial state mein ginti le sakte hain to behtar hoga.
    // Warna, pehli baar messages aane par yeh 0 se zyada hoga to scroll ho jayega.
    _previousMessageCount = 0;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    // Screen band hone par messages ko read mark karein
    _markChatAsRead();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isScreenVisible = true;
        _markChatAsRead();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _isScreenVisible = false;
        _markChatAsRead();
        break;
      case AppLifecycleState.detached:
        _markChatAsRead();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _scrollToBottom({bool animate = false}) {
    if (_scrollController.hasClients) {
      // 'reverse: true' hone ki wajah se minScrollExtent bottom hota hai
      final position = _scrollController.position.minScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(position);
      }
    }
  }

  void _markChatAsRead() {
    try {
      if (mounted && context.mounted) {
        context.read<ChatListBloc>().add(MarkChatAsRead(widget.chatRoomId));
      }
    } catch (e) {
      print('Error marking chat as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _markChatAsRead();
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                sl<ChatRoomBloc>()..add(SubscribeToMessages(widget.chatRoomId)),
          ),
          BlocProvider(create: (context) => sl<VideoCallBloc>()),
        ],
        child: Builder(
          builder: (context) {
            final authState = context.read<AuthBloc>().state;
            final currentUserId = authState.user?.id ?? '';

            return Scaffold(
              appBar: AppBar(
                title: Text(widget.chatPartnerName),
                actions: [
                  BlocBuilder<VideoCallBloc, VideoCallState>(
                    builder: (context, state) {
                      if (state is VideoCallInitiating) {
                        return const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
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
                                receiverId: widget.receiverId,
                                callerName: currentUser.name,
                                callId: widget.chatRoomId,
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
                  print("VideoCallBloc Listener received state: $state");
                  if (state is VideoCallInitiatedSuccess) {
                    final currentUser = context.read<AuthBloc>().state.user;
                    if (currentUser != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CallingScreen(
                            callID: widget.chatRoomId,
                            currentUser: currentUser,
                            doctor: widget.doctor,
                            patient: widget.patient,
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
                    Expanded(
                      child: BlocListener<ChatRoomBloc, ChatRoomState>(
                        listener: (context, state) {
                          // Auto mark as read when new messages arrive while screen is visible
                          if (state is ChatRoomLoaded &&
                              _isScreenVisible &&
                              state.messages.isNotEmpty) {
                            // Chota sa delay dein taake ListView rebuild ho sake
                            Future.delayed(const Duration(milliseconds: 500), () {
                              _markChatAsRead();
                            });
                          }
                          
                          // Naye messages aane par scroll to bottom ka logic
                          if (state is ChatRoomLoaded) {
                            final currentMessageCount = state.messages.length;
                            // Agar naye messages aaye hain aur screen visible hai
                            if (currentMessageCount > _previousMessageCount && _isScreenVisible) {
                              // Chota sa delay dein taake ListView refresh ho jaye
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollToBottom(animate: true);
                              });
                            }
                            // Messages ki ginti update karen
                            _previousMessageCount = currentMessageCount;
                          }
                        },
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
                                controller: _scrollController,
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
                    ),
                    ChatInputField(
                      chatRoomId: widget.chatRoomId,
                      receiverId: widget.receiverId,
                      doctor: widget.doctor,
                      patient: widget.patient,
                      onMessageSent: () => _scrollToBottom(animate: true),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
