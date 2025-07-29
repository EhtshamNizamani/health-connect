import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/chat/domain/entities/chat_room_entity.dart';
import 'package:health_connect/features/chat/domain/usecases/get_chat_rooms_usecase.dart';
import 'chat_list_event.dart';
import 'chat_list_state.dart';
import 'package:rxdart/rxdart.dart';
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatRoomsUseCase _getChatRoomsUseCase;
  // We no longer need to manage the subscription manually
  // StreamSubscription? _chatRoomsSubscription;

  ChatListBloc(this._getChatRoomsUseCase) : super(ChatListInitial()) {
    on<SubscribeToChatRooms>(
      _onSubscribeToChatRooms,
      // Use the switchMap transformer to prevent multiple subscriptions
      transformer: (events, mapper) => events.switchMap(mapper),
    );
  }

  // <<<--- THE FIX IS HERE ---
  Future<void> _onSubscribeToChatRooms(
    SubscribeToChatRooms event,
    Emitter<ChatListState> emit,
  ) async { // Make the handler async
    emit(ChatListLoading());

    // Use emit.onEach to safely listen to the stream from the use case
    await emit.onEach<Either<Failure, List<ChatRoomEntity>>>(
      _getChatRoomsUseCase(),
      onData: (result) {
        // This is called for every new list of chat rooms from the stream
        result.fold(
          (failure) => emit(ChatListError(failure.message)),
          (chatRooms) => emit(ChatListLoaded(chatRooms)),
        );
      },
      onError: (error, stackTrace) => emit(ChatListError(error.toString())),
    );
  }
}