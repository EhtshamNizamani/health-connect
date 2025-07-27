import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/domain/usecases/get_doctor_appointments_usecase.dart';
import 'package:health_connect/features/appointment/domain/usecases/update_appointment_status_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'doctor_appointments_event.dart';
import 'doctor_appointments_state.dart';

class DoctorAppointmentsBloc
    extends Bloc<DoctorAppointmentsEvent, DoctorAppointmentsState> {
  final GetDoctorAppointmentsUseCase _getAppointmentsUseCase;
  final UpdateAppointmentsStatusUseCase _updateStatusUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  DoctorAppointmentsBloc(
    this._getAppointmentsUseCase,
    this._updateStatusUseCase,
    this._getCurrentUserUseCase,
  ) : super(DoctorAppointmentsInitial()) {
    on<FetchDoctorAppointments>(_onFetchAppointments);
    on<ConfirmAppointment>(_onConfirmAppointment);
    on<CancelAppointment>(_onCancelAppointment);
  }
Future<void> _onFetchAppointments(
  FetchDoctorAppointments event,
  Emitter<DoctorAppointmentsState> emit,
) async {
  emit(DoctorAppointmentsLoading());
  final user = await _getCurrentUserUseCase();
  if (user == null) {
    emit(const DoctorAppointmentsError("Doctor not logged in."));
    return;
  }

  // Listen to the stream of appointments
  await emit.forEach<Either<Failure, List<AppointmentEntity>>>(
    _getAppointmentsUseCase(user.id),
    onData: (result) {
      return result.fold(
        (failure) => DoctorAppointmentsError(failure.message),
        (appointments) {
          final now = DateTime.now();

          // PENDING: New requests that need action.
          final pending = appointments
              .where((a) => a.status == 'pending')
              .toList();

          // UPCOMING: Appointments that are confirmed and are in the future.
          final upcoming = appointments
              .where((a) => a.status == 'confirmed' && a.appointmentDateTime.isAfter(now))
              .toList();

          final past = appointments
              .where((a) => a.status == 'completed' || 
                           a.status == 'cancelled' ||
                           (a.status == 'confirmed' && a.appointmentDateTime.isBefore(now)))
              .toList();
          

          return DoctorAppointmentsLoaded(
            pending: pending,
            upcoming: upcoming,
            past: past
          );
        },
      );
    },
    onError: (error, stackTrace) => DoctorAppointmentsError(error.toString()),
  );
}

  Future<void> _onConfirmAppointment(
    ConfirmAppointment event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    await _updateStatusUseCase(event.appointmentId, 'confirmed');
    // After updating, re-fetch the list to show the change
    add(FetchDoctorAppointments());
  }

  Future<void> _onCancelAppointment(
    CancelAppointment event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    await _updateStatusUseCase(event.appointmentId, 'cancelled');
    add(FetchDoctorAppointments());
  }
}