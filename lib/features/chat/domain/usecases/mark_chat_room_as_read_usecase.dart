import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:health_connect/features/chat/domain/repositories/chat_repository.dart';
import 'package:health_connect/features/chat/domain/entities/chat_room_entity.dart';

// New UseCase for optimistic updates
class MarkChatRoomAsReadOptimisticUseCase implements UseCase<OptimisticUpdateResult, MarkChatRoomAsReadParams> {
  final ChatRepository repository;

  MarkChatRoomAsReadOptimisticUseCase(this.repository);

  @override
  Future<Either<Failure, OptimisticUpdateResult>> call(MarkChatRoomAsReadParams params) async {
    try {
      // Perform the actual database operation
      final result = await repository.markChatRoomAsRead(params.chatRoomId, params.userId);
      
      return result.fold(
        (failure) => Left(failure),
        (_) => Right(OptimisticUpdateResult(
          success: true,
          chatRoomId: params.chatRoomId,
          message: 'Chat marked as read successfully',
        )),
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to mark chat as read: $e'));
    }
  }
}

// Domain entity for the result
class OptimisticUpdateResult {
  final bool success;
  final String chatRoomId;
  final String message;
  
  const OptimisticUpdateResult({
    required this.success,
    required this.chatRoomId,
    required this.message,
  });
}

// Enhanced UseCase that handles the optimistic logic
class ChatRoomOptimisticUpdater {
  final MarkChatRoomAsReadOptimisticUseCase markAsReadUseCase;
  
  ChatRoomOptimisticUpdater(this.markAsReadUseCase);
  
  /// Applies optimistic update to a chat room list
  /// Returns the updated list and the previous unread count for potential rollback
  OptimisticChatRoomUpdate applyOptimisticMarkAsRead(
    List<ChatRoomEntity> chatRooms,
    String chatRoomId,
  ) {
    final chatRoomIndex = chatRooms.indexWhere((room) => room.id == chatRoomId);
    
    if (chatRoomIndex == -1) {
      return OptimisticChatRoomUpdate(
        updatedChatRooms: chatRooms,
        previousUnreadCount: 0,
        wasUpdated: false,
      );
    }
    
    final currentChatRoom = chatRooms[chatRoomIndex];
    final previousUnreadCount = currentChatRoom.unreadCount;
    
    if (previousUnreadCount == 0) {
      return OptimisticChatRoomUpdate(
        updatedChatRooms: chatRooms,
        previousUnreadCount: 0,
        wasUpdated: false,
      );
    }
    
    // Create updated chat room with unread count = 0
    final updatedChatRoom = ChatRoomEntity(
      id: currentChatRoom.id,
      participants: currentChatRoom.participants,
      lastMessage: currentChatRoom.lastMessage,
      lastMessageTimestamp: currentChatRoom.lastMessageTimestamp,
      otherUserName: currentChatRoom.otherUserName,
      otherUserPhotoUrl: currentChatRoom.otherUserPhotoUrl,
      unreadCount: 0, // Mark as read
    );
    
    // Create new list with updated chat room
    final updatedChatRooms = List<ChatRoomEntity>.from(chatRooms);
    updatedChatRooms[chatRoomIndex] = updatedChatRoom;
    
    return OptimisticChatRoomUpdate(
      updatedChatRooms: updatedChatRooms,
      previousUnreadCount: previousUnreadCount,
      wasUpdated: true,
      chatRoomIndex: chatRoomIndex,
    );
  }
  
  /// Reverts the optimistic update if the database operation failed
  List<ChatRoomEntity> revertOptimisticUpdate(
    List<ChatRoomEntity> chatRooms,
    OptimisticChatRoomUpdate originalUpdate,
  ) {
    if (!originalUpdate.wasUpdated || originalUpdate.chatRoomIndex == null) {
      return chatRooms;
    }
    
    final currentChatRoom = chatRooms[originalUpdate.chatRoomIndex!];
    
    // Revert to original unread count
    final revertedChatRoom = ChatRoomEntity(
      id: currentChatRoom.id,
      participants: currentChatRoom.participants,
      lastMessage: currentChatRoom.lastMessage,
      lastMessageTimestamp: currentChatRoom.lastMessageTimestamp,
      otherUserName: currentChatRoom.otherUserName,
      otherUserPhotoUrl: currentChatRoom.otherUserPhotoUrl,
      unreadCount: originalUpdate.previousUnreadCount,
    );
    
    final revertedChatRooms = List<ChatRoomEntity>.from(chatRooms);
    revertedChatRooms[originalUpdate.chatRoomIndex!] = revertedChatRoom;
    
    return revertedChatRooms;
  }
}

// Result class for optimistic updates
class OptimisticChatRoomUpdate {
  final List<ChatRoomEntity> updatedChatRooms;
  final int previousUnreadCount;
  final bool wasUpdated;
  final int? chatRoomIndex;
  
  const OptimisticChatRoomUpdate({
    required this.updatedChatRooms,
    required this.previousUnreadCount,
    required this.wasUpdated,
    this.chatRoomIndex,
  });
}

// Keep the original simple UseCase as well
class MarkChatRoomAsReadUseCase implements UseCase<void, MarkChatRoomAsReadParams> {
  final ChatRepository repository;

  MarkChatRoomAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkChatRoomAsReadParams params) async {
    return await repository.markChatRoomAsRead(params.chatRoomId, params.userId);
  }
}

class MarkChatRoomAsReadParams {
  final String chatRoomId;
  final String userId;
  
  MarkChatRoomAsReadParams({required this.chatRoomId, required this.userId});
}