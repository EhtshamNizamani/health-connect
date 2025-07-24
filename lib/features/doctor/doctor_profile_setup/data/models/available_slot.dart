import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/available_slot.dart';

// This class no longer extends AvailableSlot. It's a separate data transfer object.
class AvailableSlotModel {
  final String startTime;
  final String endTime;

  const AvailableSlotModel({
    required this.startTime,
    required this.endTime,
  });

  // This method creates a Model from a Firestore map. No changes needed here.
  factory AvailableSlotModel.fromMap(Map<String, dynamic> map) {
    return AvailableSlotModel(
      startTime: map['startTime'] as String? ?? '',
      endTime: map['endTime'] as String? ?? '',
    );
  }

  // This method converts the Model to a map for Firestore. No changes needed here.
  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }
  
  // This is a helper factory to create a Model from an Entity.
  // Useful within the repository when you need to convert back.
  factory AvailableSlotModel.fromEntity(AvailableSlot entity) {
    return AvailableSlotModel(
      startTime: entity.startTime, 
      endTime: entity.endTime
    );
  }

  // THE MOST IMPORTANT METHOD:
  // This converts the Data Layer object (this Model) into a pure
  // Domain Layer object (the Entity).
  AvailableSlot toDomain() {
    return AvailableSlot(
      startTime: startTime,
      endTime: endTime,
    );
  }
}