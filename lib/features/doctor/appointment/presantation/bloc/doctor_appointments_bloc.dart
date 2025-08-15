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
    on<CompletedAppointment>(_onCompletedAppointment);
    on<ClearLoadingState>(_onClearLoadingState);
    on<MarkAsNoShow>(_onMarkAsNoShow);
  }

  Future<void> _onFetchAppointments(
    FetchDoctorAppointments event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    print("[DoctorAppointmentsBloc] 📋 Fetching appointments...");
    
    // Show full screen loader only when fetching for the first time
    if (state is! DoctorAppointmentsLoaded) {
      emit(DoctorAppointmentsLoading());
    }

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
            print("[DoctorAppointmentsBloc] 📊 Received ${appointments.length} appointments");
            
            final now = DateTime.now();

            final pending = appointments
                .where((a) => a.status == 'pending')
                .toList();

            final upcoming = appointments
                .where((a) =>
                    a.status == 'confirmed' && a.appointmentDateTime.isAfter(now))
                .toList();

            final past = appointments
                .where((a) =>
                    a.status == 'completed' ||
                    a.status == 'cancelled' ||
                    a.status == 'no-show' ||
                    (a.status == 'confirmed' &&
                        a.appointmentDateTime.isBefore(now)))
                .toList();

            print("[DoctorAppointmentsBloc] 📊 Categorized: ${pending.length} pending, ${upcoming.length} upcoming, ${past.length} past");

            // IMPORTANT: Preserve the updatingAppointmentId across stream updates
            final currentUpdatingId = state is DoctorAppointmentsLoaded
                ? (state as DoctorAppointmentsLoaded).updatingAppointmentId
                : null;

            return DoctorAppointmentsLoaded(
              pending: pending,
              upcoming: upcoming,
              past: past,
              updatingAppointmentId: currentUpdatingId,
            );
          },
        );
      },
      onError: (error, stackTrace) {
        print("[DoctorAppointmentsBloc] ❌ Stream error: $error");
        return DoctorAppointmentsError(error.toString());
      },
    );
  }

  // --- IMPROVED HELPER FUNCTION TO HANDLE ALL STATUS UPDATES ---
  Future<void> _handleStatusUpdate(
    String appointmentId,
    String newStatus,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    print("[DoctorAppointmentsBloc] 🔄 Updating appointment $appointmentId to status: $newStatus");
    
    // 1. Ensure we are in a loaded state
    if (state is! DoctorAppointmentsLoaded) {
      print("[DoctorAppointmentsBloc] ⚠️ Cannot update - not in loaded state");
      return;
    }
    final currentState = state as DoctorAppointmentsLoaded;

    // 2. Show item-specific loader
    print("[DoctorAppointmentsBloc] ⏳ Setting loading state for appointment: $appointmentId");
    emit(currentState.copyWith(updatingAppointmentId: appointmentId));

    // 3. Add a small delay to ensure the loading state is visible
    await Future.delayed(const Duration(milliseconds: 100));

    // 4. Call the use case to update the status in the database
    final result = await _updateStatusUseCase(
      appointmentId,
      newStatus,
    );

    // 5. Handle the result
    result.fold(
      (failure) {
        print("[DoctorAppointmentsBloc] ❌ Failed to update status: ${failure.message}");
        // Remove the loader and potentially show error
        if (state is DoctorAppointmentsLoaded) {
          emit((state as DoctorAppointmentsLoaded).copyWith(clearUpdatingId: true));
        }
      },
      (_) {
        print("[DoctorAppointmentsBloc] ✅ Successfully updated appointment status");
        // Add a delay before clearing the loader to show success feedback
        Future.delayed(const Duration(milliseconds: 500), () {
          if (state is DoctorAppointmentsLoaded) {
            add(ClearLoadingState()); // Use the public event
          }
        });
      },
    );
  }

  // --- EVENT HANDLERS NOW USE THE HELPER FUNCTION ---

  Future<void> _onConfirmAppointment(
    ConfirmAppointment event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    print("[DoctorAppointmentsBloc] ✅ Confirming appointment: ${event.appointmentId}");
    await _handleStatusUpdate(event.appointmentId, 'confirmed', emit);
  }

  Future<void> _onCancelAppointment(
    CancelAppointment event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    print("[DoctorAppointmentsBloc] ❌ Cancelling appointment: ${event.appointmentId}");
    await _handleStatusUpdate(event.appointmentId, 'cancelled', emit);
  }

  // Handler for clearing loading state
  void _onClearLoadingState(
    ClearLoadingState event,
    Emitter<DoctorAppointmentsState> emit,
  ) {
    print("[DoctorAppointmentsBloc] 🧹 Clearing loading state");
    if (state is DoctorAppointmentsLoaded) {
      emit((state as DoctorAppointmentsLoaded).copyWith(clearUpdatingId: true));
    }
  }

    Future<void> _onCompletedAppointment(
    CompletedAppointment event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    print("[DoctorAppointmentsBloc] ✅ Marking appointment as completed: ${event.appointmentId}");
    await _handleStatusUpdate(event.appointmentId, 'completed', emit);
  }
    Future<void> _onMarkAsNoShow(
    MarkAsNoShow event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    // Helper function ko naye status 'no-show' ke saath call karein
    await _handleStatusUpdate(event.appointmentId, 'no-show', emit);
  }
}