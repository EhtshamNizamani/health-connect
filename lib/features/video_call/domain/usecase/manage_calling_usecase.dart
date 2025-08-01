import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:health_connect/features/video_call/domain/repository/calling_repository.dart';

class ManageCallingUseCase implements UseCase<void, ManageCallingParams> {
  final CallingRepository _callingRepository;

  ManageCallingUseCase(this._callingRepository);

  @override
  Future<Either<Failure, void>> call(ManageCallingParams params) async {
    switch (params.action) {
      case CallingAction.cancel:
        return await _callingRepository.cancelCall(
          receiverId: params.receiverId!,
          callId: params.callId!,
        );
      
      case CallingAction.accept:
        return await _callingRepository.sendCallAnswer(
          callerId: params.callerId!,
          callId: params.callId!,
          accepted: true,
        );
      
      case CallingAction.reject:
        return await _callingRepository.sendCallRejection(
          callerId: params.callerId!,
          callId: params.callId!,
        );
    }
  }
}

class ManageCallingParams extends Equatable {
  final CallingAction action;
  final String? callId;
  final String? receiverId;
  final String? callerId;

  const ManageCallingParams({
    required this.action,
    this.callId,
    this.receiverId,
    this.callerId,
  });

  @override
  List<Object?> get props => [action, callId, receiverId, callerId];
}

enum CallingAction {
  cancel,
  accept,
  reject,
}
