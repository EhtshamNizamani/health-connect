import 'package:health_connect/core/data/entities/daily_availability_entity.dart';

import 'time_slot_model.dart'; // Importing another shared model

class DailyAvailabilityModel {
  final bool isWorking;
  final List<TimeSlotModel> slots;

  const DailyAvailabilityModel({required this.isWorking, required this.slots});

  factory DailyAvailabilityModel.fromMap(Map<String, dynamic> map) {
    return DailyAvailabilityModel(
      isWorking: map['isWorking'],
      slots: (map['slots'] as List).map((s) => TimeSlotModel.fromMap(s)).toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'isWorking': isWorking,
    'slots': slots.map((s) => s.toMap()).toList(),
  };
  
  DailyAvailability toDomain() => DailyAvailability(
    isWorking: isWorking,
    slots: slots.map((s) => s.toDomain()).toList(),
  );
  
  factory DailyAvailabilityModel.fromEntity(DailyAvailability entity) {
    return DailyAvailabilityModel(
      isWorking: entity.isWorking,
      slots: entity.slots.map((s) => TimeSlotModel.fromEntity(s)).toList(),
    );
  }
}