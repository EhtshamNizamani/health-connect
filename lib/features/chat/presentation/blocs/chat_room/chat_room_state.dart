import 'package:equatable/equatable.dart';
import 'package:health_connect/features/chat/domain/entities/message_entity.dart';

abstract class ChatRoomState extends Equatable {
  const ChatRoomState();
  @override
  List<Object> get props => [];
}

class ChatRoomInitial extends ChatRoomState {}
class ChatRoomLoading extends ChatRoomState {}
class ChatRoomLoaded extends ChatRoomState {
  final List<MessageEntity> messages;
  const ChatRoomLoaded(this.messages);
  @override
  List<Object> get props => [messages];
}
class ChatRoomError extends ChatRoomState {
  final String message;
  const ChatRoomError(this.message);
  @override
  List<Object> get props => [message];
}
class MessageSendSuccess extends ChatRoomState {}
class MessageSendFailure extends ChatRoomState {
  final String message;
  const MessageSendFailure(this.message);
  @override
  List<Object> get props => [message];
}

class MessageSending extends ChatRoomLoaded {
  // It should EXTEND ChatRoomLoaded so that the old messages
  // are still visible on the screen while the new one is sending.
  const MessageSending(super.messages);
}