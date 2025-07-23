import 'package:equatable/equatable.dart';

class AvailableSlot extends Equatable {
  final String startTime;
  final String endTime;

  const AvailableSlot({
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [startTime, endTime];
}