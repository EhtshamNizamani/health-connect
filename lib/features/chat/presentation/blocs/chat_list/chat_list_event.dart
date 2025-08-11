import 'package:equatable/equatable.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();
  @override
  List<Object> get props => [];
}

class SubscribeToChatRooms extends ChatListEvent {}
class MarkChatAsRead extends ChatListEvent {
  final String chatRoomId;
  const MarkChatAsRead(this.chatRoomId)
  ;
    @override
  List<Object> get props => [chatRoomId];

}
