import 'package:health_connect/features/video_call/domain/entity/call_entity.dart';

class CallModel extends CallEntity {
  const CallModel({
    required super.callId,
    required super.callerId,
    required super.receiverId,
    required super.callerName,
    required super.receiverName,
    required super.status,
    required super.createdAt,
    super.durationSeconds,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      callId: json['callId'],
      callerId: json['callerId'],
      receiverId: json['receiverId'],
      callerName: json['callerName'],
      receiverName: json['receiverName'],
      status: CallStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      durationSeconds: json['durationSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'callId': callId,
      'callerId': callerId,
      'receiverId': receiverId,
      'callerName': callerName,
      'receiverName': receiverName,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }
}
