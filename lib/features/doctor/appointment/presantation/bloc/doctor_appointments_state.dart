import 'package:equatable/equatable.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';

abstract class DoctorAppointmentsState extends Equatable {
  const DoctorAppointmentsState();
  @override
  List<Object?> get props => [];
}

class DoctorAppointmentsInitial extends DoctorAppointmentsState {}
class DoctorAppointmentsLoading extends DoctorAppointmentsState {}
class DoctorAppointmentsError extends DoctorAppointmentsState {
  final String message;
  const DoctorAppointmentsError(this.message);
  @override
  List<Object> get props => [message];
}

// This state will hold all appointments, categorized
class DoctorAppointmentsLoaded extends DoctorAppointmentsState {
  final List<AppointmentEntity> pending;
  final List<AppointmentEntity> upcoming;
  final List<AppointmentEntity> past;
  final String? updatingAppointmentId; // ID of the appointment being updated

  const DoctorAppointmentsLoaded({
    required this.pending,
    required this.upcoming,
    required this.past,
    this.updatingAppointmentId, // Can be null
  });

  @override
  List<Object?> get props => [
        pending,
        upcoming,
        past,
        updatingAppointmentId,
      ];

  // <<< --- THIS IS THE FINAL, CORRECTED copyWith METHOD ---
  DoctorAppointmentsLoaded copyWith({
    List<AppointmentEntity>? pending,
    List<AppointmentEntity>? upcoming,
    List<AppointmentEntity>? past,
    String? updatingAppointmentId,
    bool clearUpdatingId = false,
  }) {
    return DoctorAppointmentsLoaded(
      pending: pending ?? this.pending,
      upcoming: upcoming ?? this.upcoming,
      past: past ?? this.past,
      updatingAppointmentId: clearUpdatingId
          ? null
          : updatingAppointmentId ?? this.updatingAppointmentId,
    );
  }
}