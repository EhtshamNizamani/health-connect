

import 'package:flutter_bloc/flutter_bloc.dart';
// Import your centralized Use Cases
import 'package:health_connect/features/appointment/domain/usecases/get_patient_appointments_usecase.dart';
import 'package:health_connect/features/appointment/domain/usecases/update_appointment_status_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'patient_appointments_event.dart';
import 'patient_appointments_state.dart';

class PatientAppointmentsBloc
    extends Bloc<PatientAppointmentsEvent, PatientAppointmentsState> {
  final GetPatientAppointmentsUseCase _getAppointmentsUseCase;
  final UpdateAppointmentsStatusUseCase _updateStatusUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  PatientAppointmentsBloc(
    this._getAppointmentsUseCase,
    this._updateStatusUseCase,
    this._getCurrentUserUseCase,
  ) : super(PatientAppointmentsInitial()) {
    on<FetchPatientAppointments>(_onFetchAppointments);
    on<CancelPatientAppointment>(_onCancelAppointment);
  }

  Future<void> _onFetchAppointments(
    FetchPatientAppointments event,
    Emitter<PatientAppointmentsState> emit,
  ) async {
    emit(PatientAppointmentsLoading());
    final user = await _getCurrentUserUseCase();
    if (user == null) {
      emit(const PatientAppointmentsError("Patient not logged in."));
      return;
    }

    final result = await _getAppointmentsUseCase(user.id);
    result.fold(
      (failure) => emit(PatientAppointmentsError(failure.message)),
      (appointments) {
        // Categorize appointments for the patient
        final upcoming = appointments.where((a) => (a.status == 'pending' || a.status == 'confirmed') && a.appointmentDateTime.isAfter(DateTime.now())).toList();
        final past = appointments.where((a) => a.status == 'completed' || a.status == 'cancelled' || a.appointmentDateTime.isBefore(DateTime.now())).toList();
        
        emit(PatientAppointmentsLoaded(upcoming: upcoming, past: past));
      },
    );
  }

  Future<void> _onCancelAppointment(
    CancelPatientAppointment event,
    Emitter<PatientAppointmentsState> emit,
  ) async {
    // A patient can only cancel, not confirm
    await _updateStatusUseCase(event.appointmentId, 'cancelled');
    // After updating, re-fetch the list to show the change
    add(FetchPatientAppointments());
  }
}