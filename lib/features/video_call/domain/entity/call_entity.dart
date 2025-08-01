import 'package:equatable/equatable.dart';

class CallEntity extends Equatable {
  final String callId;
  final String callerId;
  final String receiverId;
  final String callerName;
  final String receiverName;
  final CallStatus status;
  final DateTime createdAt;
  final int durationSeconds;

  const CallEntity({
    required this.callId,
    required this.callerId,
    required this.receiverId,
    required this.callerName,
    required this.receiverName,
    required this.status,
    required this.createdAt,
    this.durationSeconds = 0,
  });

  @override
  List<Object> get props => [
        callId,
        callerId,
        receiverId,
        callerName,
        receiverName,
        status,
        createdAt,
        durationSeconds,
      ];
}

enum CallStatus {
  initiating,
  ringing,
  connecting,
  connected,
  ended,
  failed,
}