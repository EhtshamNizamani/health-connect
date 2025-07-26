import 'package:equatable/equatable.dart';

class TimeSlot extends Equatable {
  final String startTime; // "10:00" (24-hour format)
  final String endTime;   // "13:00"

  const TimeSlot({required this.startTime, required this.endTime});

  @override
  List<Object?> get props => [startTime, endTime];
}