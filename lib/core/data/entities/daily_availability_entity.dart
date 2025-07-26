import 'package:equatable/equatable.dart';
import 'time_slot_entity.dart'; // Importing another shared entity

class DailyAvailability extends Equatable {
  final bool isWorking;
  final List<TimeSlot> slots;

  const DailyAvailability({required this.isWorking, required this.slots});
  
  @override
  List<Object?> get props => [isWorking, slots];
}