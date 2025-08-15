import 'package:equatable/equatable.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart'; // Patient ke liye

class AppointmentDetailEntity extends Equatable {
  /// The main appointment being viewed.
  final AppointmentEntity appointment;

  /// The patient associated with this appointment.
  final UserEntity patient;

  /// A short list of the patient's most recent completed appointments.
  final List<AppointmentEntity> recentVisits;

  const AppointmentDetailEntity({
    required this.appointment,
    required this.patient,
    required this.recentVisits,
  });

  @override
  List<Object?> get props => [appointment, patient, recentVisits];
}