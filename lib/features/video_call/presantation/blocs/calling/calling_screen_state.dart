import 'package:equatable/equatable.dart';
import 'package:health_connect/features/video_call/domain/entity/calling_entity.dart';

abstract class CallingScreenState extends Equatable {
  const CallingScreenState();
  @override
  List<Object?> get props => [];
}

class CallingScreenInitial extends CallingScreenState {}

class CallingScreenLoading extends CallingScreenState {}

class CallingScreenActive extends CallingScreenState {
  final CallingEntity callingEntity;
  final bool shouldStartAnimations;
  final bool shouldNavigateToCall;

  const CallingScreenActive({
    required this.callingEntity,
    this.shouldStartAnimations = false,
    this.shouldNavigateToCall = false,
  });

  @override
  List<Object> get props => [callingEntity, shouldStartAnimations, shouldNavigateToCall];

  CallingScreenActive copyWith({
    CallingEntity? callingEntity,
    bool? shouldStartAnimations,
    bool? shouldNavigateToCall,
  }) {
    return CallingScreenActive(
      callingEntity: callingEntity ?? this.callingEntity,
      shouldStartAnimations: shouldStartAnimations ?? this.shouldStartAnimations,
      shouldNavigateToCall: shouldNavigateToCall ?? this.shouldNavigateToCall,
    );
  }
}

class CallingScreenError extends CallingScreenState {
  final String message;
  const CallingScreenError(this.message);
  @override
  List<Object> get props => [message];
}

class CallingScreenCancelled extends CallingScreenState {}

class CallingScreenNavigateToCall extends CallingScreenState {
  final String callId;
  final String currentUserId;
  final String currentUserName;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;

  const CallingScreenNavigateToCall({
    required this.callId,
    required this.currentUserId,
    required this.currentUserName,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
  });

  @override
  List<Object?> get props => [
        callId,
        currentUserId,
        currentUserName,
        otherUserId,
        otherUserName,
        otherUserPhotoUrl,
      ];
}
