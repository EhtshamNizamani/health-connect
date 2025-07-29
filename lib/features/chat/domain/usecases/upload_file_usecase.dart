import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/chat/domain/repositories/chat_repository.dart';

class UploadFileUseCase {
  final ChatRepository repository;
  UploadFileUseCase(this.repository);

  Future<Either<Failure, String>> call(File file, String chatRoomId) {
    return repository.uploadFile(file, chatRoomId);
  }
}