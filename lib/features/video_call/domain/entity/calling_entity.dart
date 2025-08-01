import 'package:equatable/equatable.dart';

class CallingEntity extends Equatable {
  final String callId;
  final String callerId;
  final String receiverId;
  final String callerName;
  final String receiverName;
  final String? receiverPhotoUrl;
  final CallState callState;
  final int durationSeconds;
  final DateTime createdAt;

  const CallingEntity({
    required this.callId,
    required this.callerId,
    required this.receiverId,
    required this.callerName,
    required this.receiverName,
    this.receiverPhotoUrl,
    required this.callState,
    this.durationSeconds = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        callId,
        callerId,
        receiverId,
        callerName,
        receiverName,
        receiverPhotoUrl,
        callState,
        durationSeconds,
        createdAt,
      ];

  CallingEntity copyWith({
    String? callId,
    String? callerId,
    String? receiverId,
    String? callerName,
    String? receiverName,
    String? receiverPhotoUrl,
    CallState? callState,
    int? durationSeconds,
    DateTime? createdAt,
  }) {
    return CallingEntity(
      callId: callId ?? this.callId,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      callerName: callerName ?? this.callerName,
      receiverName: receiverName ?? this.receiverName,
      receiverPhotoUrl: receiverPhotoUrl ?? this.receiverPhotoUrl,
      callState: callState ?? this.callState,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum CallState {
  connecting,
  ringing,
  connectingToCall,
  connected,
  ended,
  busy,
  noAnswer,
  cancelled,
}
