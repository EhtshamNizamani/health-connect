import 'package:equatable/equatable.dart';

abstract class DoctorProfileViewEvent extends Equatable {
  const DoctorProfileViewEvent();
  @override
  List<Object> get props => [];
}

class FetchDoctorDetailsViewEvent extends DoctorProfileViewEvent {
  final String doctorId;
  const FetchDoctorDetailsViewEvent(this.doctorId);
  @override
  List<Object> get props => [doctorId];
}

class FetchAvailableSlotsViewEvent extends DoctorProfileViewEvent {
  final String doctorId;
  final DateTime date;
  const FetchAvailableSlotsViewEvent({required this.doctorId, required this.date});
  @override
  List<Object> get props => [doctorId, date];
}

class TimeSlotSelected extends DoctorProfileViewEvent {
  final DateTime? slot; 
  const TimeSlotSelected(this.slot);

  @override
  List<Object> get props => [slot ?? ''];
}