import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/services/sound_service.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/chat/domain/entities/chat_room_entity.dart';
import 'package:health_connect/features/chat/domain/usecases/get_chat_rooms_usecase.dart';
import 'package:health_connect/features/chat/domain/usecases/get_total_unread_count_usecase.dart';
import 'package:health_connect/features/chat/domain/usecases/mark_chat_room_as_read_usecase.dart';
import 'chat_list_event.dart';
import 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatRoomsUseCase _getChatRoomsUseCase;
  final GetTotalUnreadCountUseCase _getTotalUnreadCountUseCase;
  final MarkChatRoomAsReadOptimisticUseCase _markChatRoomAsReadOptimisticUseCase;
  final SoundService _soundService;
  final AuthBloc _authBloc;
  final ChatRoomOptimisticUpdater _optimisticUpdater;

  StreamSubscription<Either<Failure, List<ChatRoomEntity>>>? _chatRoomsSubscription;
  StreamSubscription<Either<Failure, int>>? _unreadCountSubscription;
  
  // Keep track of current data
  List<ChatRoomEntity> _currentChatRooms = [];
  int _currentUnreadCount = 0;

  ChatListBloc(
    this._getChatRoomsUseCase,
    this._getTotalUnreadCountUseCase,
    this._markChatRoomAsReadOptimisticUseCase,
    this._optimisticUpdater,
    this._soundService,
    this._authBloc,
  ) : super(ChatListInitial()) {
    on<SubscribeToChatRooms>(_onSubscribeToChatRooms);
    on<MarkChatAsRead>(_onMarkChatAsRead);
    // Add internal events for data updates
    on<_UpdateChatRooms>(_onUpdateChatRooms);
    on<_UpdateUnreadCount>(_onUpdateUnreadCount);
    
    // Auto-subscribe when auth state changes to authenticated
    _authBloc.stream.listen((authState) {
      if (authState.user != null && state is! ChatListLoaded) {
        add(SubscribeToChatRooms());
      }
    });
  }

  Future<void> _onSubscribeToChatRooms(
    SubscribeToChatRooms event,
    Emitter<ChatListState> emit,
  ) async {
    final user = _authBloc.state.user;
    if (user?.id == null) {
      emit(const ChatListError("User not authenticated to fetch chats."));
      return;
    }

    final userId = user!.id;
    print("🚀 [ChatListBloc] Starting subscription for user: $userId");

    // Cancel existing subscriptions
    await _chatRoomsSubscription?.cancel();
    await _unreadCountSubscription?.cancel();

    emit(ChatListLoading());
    print("📱 [ChatListBloc] Emitted ChatListLoading");

    try {
      // Subscribe to chat rooms
      _chatRoomsSubscription = _getChatRoomsUseCase(userId).listen(
        (roomsResult) {
          roomsResult.fold(
            (failure) {
              print("❌ [ChatListBloc] Chat rooms error: ${failure.message}");
              add(_UpdateChatRooms(failure: failure));
            },
            (rooms) {
              print("✅ [ChatListBloc] Received ${rooms.length} chat rooms");
              add(_UpdateChatRooms(chatRooms: rooms));
            },
          );
        },
        onError: (error) {
          print("❌ [ChatListBloc] Chat rooms subscription error: $error");
          add(_UpdateChatRooms(failure: FirestoreFailure("Failed to load chat rooms: $error")));
        },
      );

      // Subscribe to unread count
      _unreadCountSubscription = _getTotalUnreadCountUseCase(userId).listen(
        (countResult) {
          countResult.fold(
            (failure) {
              print("❌ [ChatListBloc] Unread count error: ${failure.message}");
              add(_UpdateUnreadCount(unreadCount: 0)); // Don't fail for unread count
            },
            (count) {
              print("✅ [ChatListBloc] Received unread count: $count");
              add(_UpdateUnreadCount(unreadCount: count));
            },
          );
        },
        onError: (error) {
          print("❌ [ChatListBloc] Unread count subscription error: $error");
          add(_UpdateUnreadCount(unreadCount: 0)); // Don't fail for unread count
        },
      );
    } catch (e) {
      print("❌ [ChatListBloc] Failed to set up subscriptions: $e");
      emit(ChatListError("Failed to set up chat subscriptions: $e"));
      print("📱 [ChatListBloc] Emitted ChatListError: $e");
    }
  }

  Future<void> _onUpdateChatRooms(
    _UpdateChatRooms event,
    Emitter<ChatListState> emit,
  ) async {
    print("🔄 [ChatListBloc] _onUpdateChatRooms called");
    
    if (event.failure != null) {
      emit(ChatListError(event.failure!.message));
      print("📱 [ChatListBloc] Emitted ChatListError: ${event.failure!.message}");
      return;
    }

    _currentChatRooms = event.chatRooms ?? [];
    print("🔄 [ChatListBloc] Updated chat rooms: ${_currentChatRooms.length}");
    
    // Emit loaded state
    print("✅ [ChatListBloc] About to emit ChatListLoaded with ${_currentChatRooms.length} rooms and $_currentUnreadCount unread");
    
    try {
      emit(ChatListLoaded(
        chatRooms: _currentChatRooms,
        totalUnreadCount: _currentUnreadCount,
      ));
      print("📱 [ChatListBloc] Successfully emitted ChatListLoaded from chat rooms update");
    } catch (e) {
      print("❌ [ChatListBloc] Error emitting ChatListLoaded: $e");
    }
  }

  Future<void> _onUpdateUnreadCount(
    _UpdateUnreadCount event,
    Emitter<ChatListState> emit,
  ) async {
    print("🔄 [ChatListBloc] _onUpdateUnreadCount called");
    final _prevCount = _currentUnreadCount;
    _currentUnreadCount = event.unreadCount;
    print("🔄 [ChatListBloc] Updated unread count: $_currentUnreadCount");
    
    // Only emit if we already have chat rooms loaded
    if (state is ChatListLoaded) {
      print("✅ [ChatListBloc] About to emit ChatListLoaded with ${_currentChatRooms.length} rooms and $_currentUnreadCount unread");
      
      try {
        if(event.unreadCount > _prevCount){
        print("this iss unread count ${event.unreadCount } adn this is prevcount $_prevCount ${event.unreadCount > _prevCount}");

         await _soundService.playMessageSound();
        }
        emit(ChatListLoaded(
          chatRooms: _currentChatRooms,
          totalUnreadCount: _currentUnreadCount,
        ));
        print("📱 [ChatListBloc] Successfully emitted ChatListLoaded from unread count update");
      } catch (e) {
        print("❌ [ChatListBloc] Error emitting ChatListLoaded: $e");
      }
    } else {
      print("🔄 [ChatListBloc] State is not ChatListLoaded yet, waiting for chat rooms");
    }
  }

  Future<void> _onMarkChatAsRead(
    MarkChatAsRead event,
    Emitter<ChatListState> emit,
  ) async {
    final user = _authBloc.state.user;
    if (user?.id == null) {
      print("❌ [ChatListBloc] Cannot mark as read: User not authenticated");
      return;
    }

    print("📖 [ChatListBloc] Marking chat ${event.chatRoomId} as read");

    // Use domain layer for optimistic update logic
    final optimisticUpdate = _optimisticUpdater.applyOptimisticMarkAsRead(
      _currentChatRooms,
      event.chatRoomId,
    );

    if (optimisticUpdate.wasUpdated) {
      // Apply optimistic update immediately
      _currentChatRooms = optimisticUpdate.updatedChatRooms;
      _currentUnreadCount = _currentUnreadCount - optimisticUpdate.previousUnreadCount;
      
      // Emit updated state immediately
      if (state is ChatListLoaded) {
        print("✅ [ChatListBloc] Optimistically updated UI");
        emit(ChatListLoaded(
          chatRooms: _currentChatRooms,
          totalUnreadCount: _currentUnreadCount,
        ));
      }

      // Perform actual database operation
      final result = await _markChatRoomAsReadOptimisticUseCase(
        MarkChatRoomAsReadParams(
          chatRoomId: event.chatRoomId,
          userId: user!.id,
        ),
      );

      result.fold(
        (failure) {
          print("❌ [ChatListBloc] Failed to mark as read: ${failure.message}");
          
          // Revert optimistic update using domain logic
          _currentChatRooms = _optimisticUpdater.revertOptimisticUpdate(
            _currentChatRooms,
            optimisticUpdate,
          );
          _currentUnreadCount = _currentUnreadCount + optimisticUpdate.previousUnreadCount;
          
          if (state is ChatListLoaded) {
            print("⚠️ [ChatListBloc] Reverted optimistic update");
            emit(ChatListLoaded(
              chatRooms: _currentChatRooms,
              totalUnreadCount: _currentUnreadCount,
            ));
          }
        },
        (success) {
          print("✅ [ChatListBloc] Successfully marked chat as read in database");
          // Keep the optimistic update - stream will eventually sync
        },
      );
    } else {
      print("ℹ️ [ChatListBloc] Chat room not found or already read");
    }
  }


  @override
  Future<void> close() async {
    print("🔚 [ChatListBloc] Closing and cancelling subscriptions");
    await _chatRoomsSubscription?.cancel();
    await _unreadCountSubscription?.cancel();
    return super.close();
  }
}

// Internal events for data updates
class _UpdateChatRooms extends ChatListEvent {
  final List<ChatRoomEntity>? chatRooms;
  final Failure? failure;
  
  const _UpdateChatRooms({this.chatRooms, this.failure});
  
  @override
  List<Object> get props => [chatRooms ?? [], failure ?? ''];
}

class _UpdateUnreadCount extends ChatListEvent {
  final int unreadCount;
  
  const _UpdateUnreadCount({required this.unreadCount});
  
  @override
  List<Object> get props => [unreadCount];
}