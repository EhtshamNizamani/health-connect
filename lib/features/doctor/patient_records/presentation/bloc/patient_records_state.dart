import 'package:equatable/equatable.dart';
import 'package:health_connect/features/doctor/patient_records/domain/entity/patient_record_entity.dart';

abstract class PatientRecordsState extends Equatable {
  const PatientRecordsState();
  @override
  List<Object?> get props => [];
}

class PatientRecordsInitial extends PatientRecordsState {}
class PatientRecordsLoading extends PatientRecordsState {}
class PatientRecordsError extends PatientRecordsState {
  final String message;
  const PatientRecordsError(this.message);
  @override
  List<Object> get props => [message];
}

class PatientRecordsLoaded extends PatientRecordsState {
  /// The original, complete list of patients fetched from the repository.
  final List<PatientRecordEntity> allPatients;
  /// The list of patients currently visible to the user after filtering and searching.
  final List<PatientRecordEntity> filteredPatients;
  /// The currently active filter.
  final String activeFilter;

  const PatientRecordsLoaded({
    required this.allPatients,
    required this.filteredPatients,
    this.activeFilter = "All",
  });

  @override
  List<Object> get props => [allPatients, filteredPatients, activeFilter];
}