import 'package:equatable/equatable.dart';
import 'package:health_connect/features/chat/domain/entities/chat_room_entity.dart';

abstract class ChatListState extends Equatable {
  const ChatListState();
  @override
  List<Object> get props => [];
}

class ChatListInitial extends ChatListState {}
class ChatListLoading extends ChatListState {}
// ...
class ChatListLoaded extends ChatListState {
  final List<ChatRoomEntity> chatRooms;
  final int totalUnreadCount; // <<< --- NAYI PROPERTY ---

  const ChatListLoaded({
    required this.chatRooms,
    required this.totalUnreadCount,
  });

  @override
  List<Object> get props => [chatRooms, totalUnreadCount];
}
class ChatListError extends ChatListState {
  final String message;
  const ChatListError(this.message);
  @override
  List<Object> get props => [message];
}