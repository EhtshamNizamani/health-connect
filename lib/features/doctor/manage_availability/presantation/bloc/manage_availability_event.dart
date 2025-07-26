

import 'package:equatable/equatable.dart';
import 'package:health_connect/core/data/entities/time_slot_entity.dart';

abstract class ManageAvailabilityEvent extends Equatable {
  const ManageAvailabilityEvent();
  @override
  List<Object?> get props => [];
}

// 1. Event to fetch the doctor's current schedule when the screen opens
class LoadInitialSchedule extends ManageAvailabilityEvent {}

// 2. Event when the doctor toggles a day on or off
class DayToggled extends ManageAvailabilityEvent {
  final String day;
  final bool isWorking;
  const DayToggled({required this.day, required this.isWorking});
  @override
  List<Object?> get props => [day, isWorking];
}

// 3. Event to add a new time slot to a day
class TimeSlotAdded extends ManageAvailabilityEvent {
  final String day;
  final TimeSlot newSlot;
  const TimeSlotAdded({required this.day, required this.newSlot});
  @override
  List<Object?> get props => [day, newSlot];
}

// 4. Event to remove an existing time slot from a day
class TimeSlotRemoved extends ManageAvailabilityEvent {
  final String day;
  final TimeSlot slotToRemove;
  const TimeSlotRemoved({required this.day, required this.slotToRemove});
  @override
  List<Object?> get props => [day, slotToRemove];
}

// 5. Event to save the entire updated schedule to Firestore
class ScheduleSaved extends ManageAvailabilityEvent {}