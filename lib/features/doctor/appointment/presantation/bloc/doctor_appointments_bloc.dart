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
        return result.fold((failure) => DoctorAppointmentsError(failure.message), (
          appointments,
        ) {
          print(
            "[DoctorAppointmentsBloc] 📊 Received ${appointments.length} appointments",
          );

          final now = DateTime.now();

          final pending = appointments
              .where(
                (a) =>
                    a.status == 'pending' && a.appointmentDateTime.isAfter(now),
              )
              .toList();

          final upcoming = appointments
              .where(
                (a) =>
                    a.status == 'confirmed' &&
                    a.appointmentDateTime.isAfter(now),
              )
              .toList();

          final past = appointments
              .where(
                (a) =>
                    a.status == 'completed' ||
                    a.status == 'cancelled' ||
                    a.status == 'no-show' ||
                    a.status == 'expired' ||
                    (a.status == 'confirmed' &&
                        a.appointmentDateTime.isBefore(now)),
              )
              .toList();

          print(
            "[DoctorAppointmentsBloc] 📊 Categorized: ${pending.length} pending, ${upcoming.length} upcoming, ${past.length} past",
          );

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
        });
      },
      onError: (error, stackTrace) {
        print("[DoctorAppointmentsBloc] ❌ Stream error: $error");
        return DoctorAppointmentsError(error.toString());
      },
    );
  }

  // --- THE MAIN FIX IS IN THIS HELPER FUNCTION ---
  Future<void> _handleStatusUpdate(
    String appointmentId,
    String newStatus,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    if (state is! DoctorAppointmentsLoaded) return;
    final currentState = state as DoctorAppointmentsLoaded;

    // 1. Show item-specific loader
    emit(currentState.copyWith(updatingAppointmentId: appointmentId));

    // 2. Call the use case to update the status in the database
    final result = await _updateStatusUseCase(appointmentId, newStatus);

    // 3. Handle the result
    result.fold(
      (failure) {
        // On failure, just remove the loader
        emit(currentState.copyWith(clearUpdatingId: true));
        // You could also emit an error state to show a SnackBar
      },
      (_) {
        // --- 4. OPTIMISTIC UI UPDATE (THE MAGIC) ---
        // On success, DON'T wait for the stream. Manually update the state NOW.

        // Find the appointment in the current lists
        final allAppointments = [
          ...currentState.pending,
          ...currentState.upcoming,
          ...currentState.past,
        ];
        final index = allAppointments.indexWhere((a) => a.id == appointmentId);

        if (index != -1) {
          // Create a new, updated instance of the appointment
          final updatedAppointment = allAppointments[index].copyWith(
            status: newStatus,
          );
          // Replace the old one with the new one
          allAppointments[index] = updatedAppointment;

          // Re-categorize the now-updated list
          final categorized = _categorizeAppointments(allAppointments);

          // Emit a new loaded state with the updated lists and clear the loader
          emit(
            DoctorAppointmentsLoaded(
              pending: categorized['pending']!,
              upcoming: categorized['upcoming']!,
              past: categorized['past']!,
              updatingAppointmentId: null, // Loader is now cleared
            ),
          );
        } else {
          // If for some reason the appointment wasn't found, just clear the loader
          emit(currentState.copyWith(clearUpdatingId: true));
        }
      },
    );
  }

  // --- NEW HELPER FUNCTION to avoid repeating categorization logic ---
  Map<String, List<AppointmentEntity>> _categorizeAppointments(
    List<AppointmentEntity> appointments,
  ) {
    final now = DateTime.now();
    final pending = appointments
        .where(
          (a) => a.status == 'pending' && a.appointmentDateTime.isAfter(now),
        )
        .toList();
    final upcoming = appointments
        .where(
          (a) => a.status == 'confirmed' && a.appointmentDateTime.isAfter(now),
        )
        .toList();
    final past = appointments
        .where(
          (a) =>
              a.status == 'completed' ||
              a.status == 'cancelled' ||
              a.status == 'no-show' ||
              a.status == 'expired' ||
              (a.status == 'confirmed' && a.appointmentDateTime.isBefore(now) ||
                  (a.status == 'pending' &&
                      a.appointmentDateTime.isBefore(now))),
        )
        .toList();

    return {'pending': pending, 'upcoming': upcoming, 'past': past};
  }

  // --- EVENT HANDLERS NOW USE THE HELPER FUNCTION ---

  Future<void> _onConfirmAppointment(
    ConfirmAppointment event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    print(
      "[DoctorAppointmentsBloc] ✅ Confirming appointment: ${event.appointmentId}",
    );
    await _handleStatusUpdate(event.appointmentId, 'confirmed', emit);
  }

  Future<void> _onCancelAppointment(
    CancelAppointment event,
    Emitter<DoctorAppointmentsState> emit,
  ) async {
    print(
      "[DoctorAppointmentsBloc] ❌ Cancelling appointment: ${event.appointmentId}",
    );
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
    print(
      "[DoctorAppointmentsBloc] ✅ Marking appointment as completed: ${event.appointmentId}",
    );
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
