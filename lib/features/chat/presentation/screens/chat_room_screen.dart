import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_event.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_state.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_event.dart';
import 'package:health_connect/features/chat_access/bloc/chat_access_bloc.dart';
import 'package:health_connect/features/chat_access/bloc/chat_access_event.dart';
import 'package:health_connect/features/chat_access/bloc/chat_access_state.dart';
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
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _markChatAsRead();
    _previousMessageCount = 0;

    // Periodically refresh chat access to handle real-time status changes
    _startPeriodicAccessCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _markChatAsRead();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isScreenVisible = true;
        _markChatAsRead();
        // Refresh access when app comes back to foreground
        _refreshChatAccess();
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

  void _startPeriodicAccessCheck() {
    // Check access every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _refreshChatAccess();
        _startPeriodicAccessCheck(); // Continue the cycle
      }
    });
  }

  void _refreshChatAccess() {
    final chatAccessBloc = context.read<ChatAccessBloc>();
    final authState = context.read<AuthBloc>().state;

    // Determine current user type
    UserType currentUserType;
    if (authState is AuthenticatedPatient) {
      currentUserType = UserType.patient;
    } else if (authState is AuthenticatedDoctorProfileExists) {
      currentUserType = UserType.doctor;
    } else {
      print("Warning: Unknown user type in chat access refresh");
      return;
    }

    chatAccessBloc.add(
      RefreshChatAccess(
        patientId: widget.patient.id,
        doctorId: widget.doctor.uid,
        currentUserType: currentUserType,
      ),
    );
  }

  void _scrollToBottom({bool animate = false}) {
    if (_scrollController.hasClients) {
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

  void _showAccessDeniedDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Chat Access Expired'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close chat screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                  // Video call button - only show if chat access is allowed
                  BlocBuilder<ChatAccessBloc, ChatAccessState>(
                    builder: (context, chatAccessState) {
                      if (chatAccessState is ChatAccessAllowed) {
                        return BlocBuilder<VideoCallBloc, VideoCallState>(
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
                                final currentUser = context
                                    .read<AuthBloc>()
                                    .state
                                    .user;
                                if (currentUser != null) {
                                  print("Dispatching StartCall event...");
                                  context.read<VideoCallBloc>().add(
                                    StartCall(
                                      receiverId: widget.receiverId,
                                      currentUser: currentUser,
                                      callId: widget.chatRoomId,
                                      doctor: widget.doctor,
                                      patient: widget.patient,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              body: BlocListener<VideoCallBloc, VideoCallState>(
                listener: (context, state) {
                  print("VideoCallBloc Listener received state: $state");
                  if (state is NavigateToCallingScreen) {
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
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                child: BlocListener<ChatAccessBloc, ChatAccessState>(
                  listener: (context, chatAccessState) {
                    // Handle chat access changes
                    if (chatAccessState is ChatAccessDenied) {
                      _showAccessDeniedDialog(chatAccessState.reason);
                    }
                  },
                  child: Column(
                    children: [
                      // Chat Access Status Banner
                      BlocBuilder<ChatAccessBloc, ChatAccessState>(
                        builder: (context, chatAccessState) {
                          if (chatAccessState is ChatAccessDenied) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              color: Colors.orange.withOpacity(0.1),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Chat access expired. Book a new appointment to continue.',
                                      style: TextStyle(
                                        color: Colors.orange.shade800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      Expanded(
                        child: BlocListener<ChatRoomBloc, ChatRoomState>(
                          listener: (context, state) {
                            if (state is ChatRoomLoaded &&
                                _isScreenVisible &&
                                state.messages.isNotEmpty) {
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  _markChatAsRead();
                                },
                              );
                            }

                            if (state is ChatRoomLoaded) {
                              final currentMessageCount = state.messages.length;
                              if (currentMessageCount > _previousMessageCount &&
                                  _isScreenVisible) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  _scrollToBottom(animate: true);
                                });
                              }
                              _previousMessageCount = currentMessageCount;
                            }
                          },
                          child: BlocBuilder<ChatRoomBloc, ChatRoomState>(
                            builder: (context, state) {
                              if (state is ChatRoomLoading ||
                                  state is ChatRoomInitial) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
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
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16.0),
                                  reverse: true,
                                  itemCount: state.messages.length,
                                  itemBuilder: (context, index) {
                                    final message = state.messages[index];
                                    final bool isMe =
                                        message.senderId == currentUserId;
                                    return MessageBubble(
                                      key: ValueKey(message.id),
                                      message: message,
                                      isMe: isMe,
                                    );
                                  },
                                );
                              }
                              return const Center(
                                child: Text("Something went wrong"),
                              );
                            },
                          ),
                        ),
                      ),

                      // Chat Input - conditional based on access
                      BlocBuilder<ChatAccessBloc, ChatAccessState>(
                        builder: (context, chatAccessState) {
                          if (chatAccessState is ChatAccessAllowed) {
                            return ChatInputField(
                              chatRoomId: widget.chatRoomId,
                              receiverId: widget.receiverId,
                              doctor: widget.doctor,
                              patient: widget.patient,
                              onMessageSent: () =>
                                  _scrollToBottom(animate: true),
                            );
                          }

                          if (chatAccessState is ChatAccessDenied) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.block,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Chat is disabled. Please book a new appointment.',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Show loading state
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
