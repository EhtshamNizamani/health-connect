import 'package:equatable/equatable.dart';

abstract class DoctorProfileViewEvent extends Equatable {
  const DoctorProfileViewEvent();
  @override
  List<Object> get props => [];
}

// Event to trigger fetching the doctor's details
class FetchDoctorDetails extends DoctorProfileViewEvent {
  final String doctorId;
  const FetchDoctorDetails(this.doctorId);
  
  @override
  List<Object> get props => [doctorId];
}