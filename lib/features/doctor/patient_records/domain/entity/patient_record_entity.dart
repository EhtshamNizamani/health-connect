import 'package:equatable/equatable.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';

class PatientRecordEntity extends Equatable {
  final UserEntity patient;
  final DateTime? lastVisit; // Can be null if it's a new patient with no appointments

  const PatientRecordEntity({
    required this.patient,
    this.lastVisit,
  });

  @override
  List<Object?> get props => [patient, lastVisit];
}