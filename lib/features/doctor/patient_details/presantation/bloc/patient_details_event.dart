
import 'package:equatable/equatable.dart';

abstract class PatientDetailEvent extends Equatable {
  const PatientDetailEvent();
  @override
  List<Object> get props => [];
}

class FetchPatientDetails extends PatientDetailEvent {
  final String patientId;
  const FetchPatientDetails(this.patientId);
  @override
  List<Object> get props => [patientId];
}