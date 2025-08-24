import 'package:equatable/equatable.dart';
import 'package:health_connect/features/doctor/patient_details/domain/entity/patient_details_entity.dart';

abstract class PatientDetailState extends Equatable {
  const PatientDetailState();
  @override
  List<Object?> get props => [];
}

class PatientDetailInitial extends PatientDetailState {}
class PatientDetailLoading extends PatientDetailState {}
class PatientDetailError extends PatientDetailState {
  final String message;
  const PatientDetailError(this.message);
  @override
  List<Object> get props => [message];
}

class PatientDetailLoaded extends PatientDetailState {
  final PatientDetailEntity details;
  const PatientDetailLoaded(this.details);
  @override
  List<Object> get props => [details];
}