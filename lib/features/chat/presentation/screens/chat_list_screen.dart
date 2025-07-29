import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/chat/domain/entities/chat_room_entity.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_event.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_state.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:intl/intl.dart';
import 'chat_room_screen.dart';


class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChatListBloc>()..add(SubscribeToChatRooms()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          automaticallyImplyLeading: false, // Assuming this is a tab in main navigation
        ),
        body: BlocBuilder<ChatListBloc, ChatListState>(
          builder: (context, state) {
            if (state is ChatListLoading || state is ChatListInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChatListError) {
              return Center(child: Text(state.message));
            }
            if (state is ChatListLoaded) {
              if (state.chatRooms.isEmpty) {
                return const Center(
                  child: Text("Your conversations with doctors will appear here."),
                );
              }
              
              // We need the current user to figure out the other participant's ID
              final authState = context.read<AuthBloc>().state;
              if (authState is! AuthenticatedPatient && authState is! AuthenticatedDoctorProfileExists && authState is! AuthenticatedDoctorProfileNotExists) {
                  return const Center(child: Text("Cannot load chats. User not authenticated."));
              }
              final currentUser = (authState as dynamic).user;


              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: state.chatRooms.length,
                separatorBuilder: (context, index) => const Divider(indent: 80, endIndent: 16),
                itemBuilder: (context, index) {
                  final chatRoom = state.chatRooms[index];
                  
                  String receiverId = chatRoom.participants.firstWhere((id) => id != currentUser.id, orElse: () => '');
                  
                  return ChatListItem(
                    chatRoom: chatRoom,
                    onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(
                              chatRoomId: chatRoom.id,
                              chatPartnerName: chatRoom.otherUserName,
                              receiverId: receiverId,
                              patient: currentUser as UserEntity,
                              doctor: DoctorEntity(uid: receiverId, name: chatRoom.otherUserName, photoUrl: chatRoom.otherUserPhotoUrl, email: '', specialization: '', bio: '', experience: 0, clinicAddress: '', consultationFee: 0, weeklyAvailability: {}),
                            ),
                          ),
                        );
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// --- Helper Widget for a single item in the chat list ---
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
    
    // Format the timestamp nicely
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
          ? Text(chatRoom.otherUserName.isNotEmpty ? chatRoom.otherUserName[0].toUpperCase() : '?', 
            style: const TextStyle(fontWeight: FontWeight.bold)) 
          : null,
      ),
      title: Text(chatRoom.otherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        chatRoom.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        timestampText,
        style: theme.textTheme.bodySmall,
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final messageDate = timestamp.toDate();
    final difference = now.difference(messageDate);

    if (difference.inDays == 0) {
      // Today
      return DateFormat('hh:mm a').format(messageDate);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Older than yesterday
      return DateFormat('MMM d').format(messageDate);
    }
  }
}