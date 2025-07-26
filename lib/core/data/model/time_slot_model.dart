import 'package:health_connect/core/data/entities/time_slot_entity.dart';

class TimeSlotModel {
  final String startTime;
  final String endTime;

  const TimeSlotModel({required this.startTime, required this.endTime});

  factory TimeSlotModel.fromMap(Map<String, dynamic> map) => TimeSlotModel(startTime: map['startTime'], endTime: map['endTime']);
  Map<String, dynamic> toMap() => {'startTime': startTime, 'endTime': endTime};
  TimeSlot toDomain() => TimeSlot(startTime: startTime, endTime: endTime);
  factory TimeSlotModel.fromEntity(TimeSlot entity) => TimeSlotModel(startTime: entity.startTime, endTime: entity.endTime);
}