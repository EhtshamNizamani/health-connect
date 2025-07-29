import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/chat/domain/entities/message_entity.dart';
import 'package:rxdart/rxdart.dart';
import 'package:health_connect/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:health_connect/features/chat/domain/usecases/send_message_usecase.dart';
import 'chat_room_event.dart';
import 'chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;

  ChatRoomBloc(this._getMessagesUseCase, this._sendMessageUseCase) : super(ChatRoomInitial()) {
    on<SubscribeToMessages>(
      _onSubscribeToMessages,
      transformer: (events, mapper) => events.switchMap(mapper),
    );
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onSubscribeToMessages(
    SubscribeToMessages event,
    Emitter<ChatRoomState> emit,
  ) async { // Make the handler async
    emit(ChatRoomLoading());
    
    // Use emit.onEach to safely listen to the stream
    await emit.onEach<Either<Failure, List<MessageEntity>>>( // Specify the type of data from the stream
      _getMessagesUseCase(event.chatRoomId),
      onData: (result) {
        // This is called for every new list of messages from the stream
        result.fold(
          (failure) => emit(ChatRoomError(failure.message)),
          (messages) => emit(ChatRoomLoaded(messages)),
        );
      },
      onError: (error, stackTrace) => emit(ChatRoomError(error.toString())),
    );
  }

Future<void> _onSendMessage(
  SendMessage event,
  Emitter<ChatRoomState> emit,
) async {
  final result = await _sendMessageUseCase(
     event.chatRoomId,
     event.message,
     event.patient,
     event.doctor,
  );
  result.fold(
    (failure) => emit(MessageSendFailure(failure.message)),
    (_) => null,
  );
}

}