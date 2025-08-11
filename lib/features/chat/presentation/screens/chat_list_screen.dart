import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/chat/domain/entities/chat_room_entity.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_event.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_state.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:intl/intl.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the subscription when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatListBloc>().add(SubscribeToChatRooms());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: BlocConsumer<ChatListBloc, ChatListState>(
          listener: (context, state) {
            // Handle any side effects here if needed
            if (state is ChatListError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            print("🖥️ [ChatListScreen] Current state: ${state.runtimeType}");
        
            if (state is ChatListLoading || state is ChatListInitial) {
              return const Center(child: CircularProgressIndicator());
            }
        
            if (state is ChatListError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load messages',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ChatListBloc>().add(SubscribeToChatRooms());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
        
            if (state is ChatListLoaded) {
              print("🖥️ [ChatListScreen] Loaded ${state.chatRooms.length} chat rooms, unread: ${state.totalUnreadCount}");
        
              if (state.chatRooms.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your conversations with doctors will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }
        
              // Get current user for navigation
              final authState = context.read<AuthBloc>().state;
              if (authState.user == null) {
                return const Center(
                  child: Text("Cannot load chats. User not authenticated."),
                );
              }
              final currentUser = authState.user!;
        
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ChatListBloc>().add(SubscribeToChatRooms());
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: state.chatRooms.length,
                  separatorBuilder: (context, index) =>
                      const Divider(indent: 80, endIndent: 16),
                  itemBuilder: (context, index) {
                    final chatRoom = state.chatRooms[index];
                    
                    String receiverId = chatRoom.participants.firstWhere(
                      (id) => id != currentUser.id,
                      orElse: () => '',
                    );
        
                    return ChatListItem(
                      chatRoom: chatRoom,
                      onTap: () => _navigateToChatRoom(
                        context,
                        chatRoom,
                        receiverId,
                        currentUser,
                      ),
                    );
                  },
                ),
              );
            }
        
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _navigateToChatRoom(
    BuildContext context,
    ChatRoomEntity chatRoom,
    String receiverId,
    UserEntity currentUser,
  ) {
    // Mark chat as read when opening
    if (chatRoom.unreadCount > 0) {
      context.read<ChatListBloc>().add(
        MarkChatAsRead(chatRoom.id),
      );
    }

    // Determine patient and doctor entities
    UserEntity patient;
    DoctorEntity doctor;

    if (currentUser.role == 'patient') {
      patient = currentUser;
      doctor = DoctorEntity(
        uid: receiverId,
        name: chatRoom.otherUserName,
        photoUrl: chatRoom.otherUserPhotoUrl,
        email: '',
        specialization: '',
        bio: '',
        experience: 0,
        clinicAddress: '',
        consultationFee: 0,
        weeklyAvailability: {},
      );
    } else if (currentUser.role == 'doctor') {
      doctor = DoctorEntity(
        uid: currentUser.id,
        name: currentUser.name,
        photoUrl: currentUser.photoUrl ?? '',
        email: currentUser.email,
        specialization: '',
        bio: '',
        experience: 0,
        clinicAddress: '',
        consultationFee: 0,
        weeklyAvailability: {},
      );
      patient = UserEntity(
        id: receiverId,
        name: chatRoom.otherUserName,
        email: '',
        role: 'patient',
        photoUrl: chatRoom.otherUserPhotoUrl,
      );
    } else {
      // Fallback
      patient = currentUser;
      doctor = DoctorEntity(
        uid: receiverId,
        name: chatRoom.otherUserName,
        photoUrl: chatRoom.otherUserPhotoUrl,
        email: '',
        specialization: '',
        bio: '',
        experience: 0,
        clinicAddress: '',
        consultationFee: 0,
        weeklyAvailability: {},
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          chatRoomId: chatRoom.id,
          chatPartnerName: chatRoom.otherUserName,
          receiverId: receiverId,
          patient: patient,
          doctor: doctor,
        ),
      ),
    );
  }
}

// Helper Widget for a single item in the chat list
class ChatListItem extends StatelessWidget {
  final ChatRoomEntity chatRoom;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.chatRoom,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String timestampText = _formatTimestamp(chatRoom.lastMessageTimestamp);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: theme.colorScheme.primaryContainer,
        backgroundImage: chatRoom.otherUserPhotoUrl.isNotEmpty
            ? NetworkImage(chatRoom.otherUserPhotoUrl)
            : null,
        child: chatRoom.otherUserPhotoUrl.isEmpty
            ? Text(
                chatRoom.otherUserName.isNotEmpty
                    ? chatRoom.otherUserName[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(
        chatRoom.otherUserName,
        style: TextStyle(
          fontWeight: chatRoom.unreadCount > 0
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        chatRoom.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: chatRoom.unreadCount > 0
              ? FontWeight.w600
              : FontWeight.normal,
          color: chatRoom.unreadCount > 0
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withAlpha(150),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(timestampText, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          if (chatRoom.unreadCount > 0)
            Badge(
              label: Text(chatRoom.unreadCount.toString()),
              backgroundColor: theme.colorScheme.primary,
            )
          else
            const SizedBox(height: 18),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final messageDate = timestamp.toDate();
    final difference = now.difference(messageDate);

    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(messageDate);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(messageDate);
    }
  }
}