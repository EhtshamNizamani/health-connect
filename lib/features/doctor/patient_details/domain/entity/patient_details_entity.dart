import 'package:equatable/equatable.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';

class PatientDetailEntity extends Equatable {
  /// The patient whose details are being viewed.
  final UserEntity patient;

  /// A complete list of all appointments (past, present, future) for this patient.
  final List<AppointmentEntity> allAppointments;
  
  // You can add more aggregated data here later if needed,
  // e.g., total appointments, total spent, etc.

  const PatientDetailEntity({
    required this.patient,
    required this.allAppointments,
  });

  @override
  List<Object?> get props => [patient, allAppointments];
}