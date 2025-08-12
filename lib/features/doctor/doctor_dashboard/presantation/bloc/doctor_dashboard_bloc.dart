import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/domain/entities/doctor_dashboard_entity.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/domain/usecase/get_doctor_dashboard_data_usecase.dart';

part 'doctor_dashboard_event.dart';
part 'doctor_dashboard_state.dart';

class DoctorDashboardBloc extends Bloc<DoctorDashboardEvent, DoctorDashboardState> {
  final GetDoctorDashboardDataUseCase _getDashboardDataUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  DoctorDashboardBloc(
    this._getDashboardDataUseCase,
    this._getCurrentUserUseCase,
  ) : super(DoctorDashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DoctorDashboardState> emit,
  ) async {
    // Show the loading state (for the skeleton UI) immediately.
    emit(DoctorDashboardLoading());

    // First, get the current authenticated user.
    final userResult = await _getCurrentUserUseCase();
    
    // The user might not be logged in, handle this case.
    if (userResult == null || userResult.role != 'doctor') {
      emit(const DoctorDashboardError("No authenticated doctor found. Please log in again."));
      return;
    }
    final doctorId = userResult.id;

    // Call the UseCase. This returns a Future<Either<Failure, Stream<...>>>.
    final streamResult = await _getDashboardDataUseCase(doctorId);

    // Handle the result of the Future.
    // The `fold` method from dartz helps handle Left (Failure) and Right (Success) cases.
    await streamResult.fold(
      (failure) {
        // This case handles errors that occur while TRYING to start the stream.
        emit(DoctorDashboardError(failure.message));
      },
      (dashboardStream) {
        // If we successfully get the stream, we listen to it using emit.forEach.
        // This is a BLoC helper that manages the stream subscription for us.
        return emit.forEach<Either<Failure, DoctorDashboardEntity>>(
          dashboardStream,
          onData: (eitherDashboardData) {
            // This `onData` callback runs every time the stream emits a new value.
            return eitherDashboardData.fold(
              (failure) => DoctorDashboardError(failure.message),
              (dashboardData) => DoctorDashboardLoaded(dashboardData),
            );
          },
          onError: (error, stackTrace) {
            // This handles any unexpected errors within the stream itself.
            return DoctorDashboardError(error.toString());
          },
        );
      },
    );
  }
}