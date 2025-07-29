import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/chat/domain/entities/message_entity.dart';
import 'package:health_connect/features/chat/domain/usecases/upload_file_usecase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:health_connect/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:health_connect/features/chat/domain/usecases/send_message_usecase.dart';
import 'chat_room_event.dart';
import 'chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final UploadFileUseCase _uploadFileUseCase; // <<<--- NEW USE CASE

  ChatRoomBloc(this._getMessagesUseCase, this._sendMessageUseCase, this._uploadFileUseCase) : super(ChatRoomInitial()) {
    on<SubscribeToMessages>(
      _onSubscribeToMessages,
      transformer: (events, mapper) => events.switchMap(mapper),
    );
    on<SendMessage>(_onSendMessage);
    on<SendFileMessage>(_onSendFileMessage);
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
  Future<void> _onSendFileMessage(
    SendFileMessage event,
    Emitter<ChatRoomState> emit,
  ) async {
  final currentState = state;
  List<MessageEntity> currentMessages = [];
  if (currentState is ChatRoomLoaded) {
    currentMessages = currentState.messages;
  }  emit(MessageSending(currentMessages));

    // 1. Upload the file to Firebase Storage
    final uploadResult = await _uploadFileUseCase(event.file, event.chatRoomId);

    await uploadResult.fold(
      (failure) {
        // If upload fails, emit a failure state
        emit(MessageSendFailure(failure.message));
      },
      (fileUrl) async {
        // 2. If upload succeeds, create a new message entity with the URL
        final message = MessageEntity(
          id: '',
          senderId: event.patient.id, // Assuming patient is sending
          receiverId: event.receiverId,
          content: event.messageType == 'image' ? '📷 Photo' : '📄 Document', // Placeholder text
          type: event.messageType,
          timestamp: Timestamp.now(),
          fileUrl: fileUrl, // The most important part!
        );

        // 3. Send the message document to Firestore
        final sendResult = await _sendMessageUseCase(
          event.chatRoomId,
        message,
       event.patient,
         event.doctor,
        );

        sendResult.fold(
          (failure) => emit(MessageSendFailure(failure.message)),
          (_) => null, // Success is handled by the stream
        );
      },
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