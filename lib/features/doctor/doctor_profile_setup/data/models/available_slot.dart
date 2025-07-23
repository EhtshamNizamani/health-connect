import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/available_slot.dart';

class AvailableSlotModel extends AvailableSlot {
  const AvailableSlotModel({
    required super.startTime,
    required super.endTime,
  });

  factory AvailableSlotModel.fromMap(Map<String, dynamic> map) {
    return AvailableSlotModel(
      startTime: map['startTime'] as String? ?? '',
      endTime: map['endTime'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory AvailableSlotModel.fromEntity(AvailableSlot entity) {
    return AvailableSlotModel(
        startTime: entity.startTime, 
        endTime: entity.endTime
    );
  }
}