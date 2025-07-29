import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/chat/domain/entities/message_entity.dart';
import 'package:health_connect/features/chat/domain/repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;
  GetMessagesUseCase(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call(String chatRoomId) {
    return repository.getMessages(chatRoomId);
  }
}