import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/chat/domain/entities/chat_room_entity.dart';
import 'package:health_connect/features/chat/domain/repositories/chat_repository.dart';

class GetChatRoomsUseCase {
  final ChatRepository repository;
  GetChatRoomsUseCase(this.repository);

  Stream<Either<Failure, List<ChatRoomEntity>>> call() {
    return repository.getChatRooms();
  }
}