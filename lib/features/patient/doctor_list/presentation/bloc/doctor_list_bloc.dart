import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/patient/doctor_list/domain/usecases/get_doctors_usecase.dart';
import 'doctor_list_event.dart';
import 'doctor_list_state.dart';

class DoctorListBloc extends Bloc<DoctorListEvent, DoctorListState> {
  final GetDoctorsUseCase _getDoctorsUseCase;

  DoctorListBloc(this._getDoctorsUseCase) : super(DoctorListState.initial()) {
    on<FetchInitialDoctors>(_onFetchInitialDoctors);
    on<FetchMoreDoctors>(
      _onFetchMoreDoctors,
      // transformer: droppable(), // Prevents spamming the event
    );
  }

  /// Handles fetching the very first page of doctors.
  Future<void> _onFetchInitialDoctors(
    FetchInitialDoctors event,
    Emitter<DoctorListState> emit,
  ) async {
    emit(state.copyWith(isLoadingFirstPage: true, errorMessage: null, doctors: [], hasReachedMax: false));
    
    // <<<--- THE FIX ---
    // Call the use case with the GetDoctorsParams object.
    // For the initial fetch, we don't provide a lastDocument.
    final result = await _getDoctorsUseCase(const GetDoctorsParams());
    // <<<----------------->>>
    
    result.fold(
      (failure) => emit(state.copyWith(isLoadingFirstPage: false, errorMessage: failure.message)),
      (page) => emit(state.copyWith(
        isLoadingFirstPage: false,
        doctors: page.doctors,
        lastDocument: page.lastDocument,
        hasReachedMax: !page.hasMore,
      )),
    );
  }

  /// Handles fetching subsequent pages of doctors.
  Future<void> _onFetchMoreDoctors(
    FetchMoreDoctors event,
    Emitter<DoctorListState> emit,
  ) async {
    // If we're already loading or have reached the end, do nothing.
    if (state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(isLoadingMore: true));
    
    // <<<--- THE FIX ---
    // Call the use case with the GetDoctorsParams object.
    // This time, we provide the 'lastDocument' from the current state.
    final result = await _getDoctorsUseCase(
      GetDoctorsParams(lastDocument: state.lastDocument),
    );
    // <<<----------------->>>

    result.fold(
      (failure) => emit(state.copyWith(isLoadingMore: false, errorMessage: failure.message)),
      (page) {
        if (page.doctors.isEmpty) {
          emit(state.copyWith(isLoadingMore: false, hasReachedMax: true));
        } else {
          // Append the new doctors to the existing list
          emit(state.copyWith(
            isLoadingMore: false,
            doctors: List.of(state.doctors)..addAll(page.doctors),
            lastDocument: page.lastDocument,
            hasReachedMax: !page.hasMore,
          ));
        }
      },
    );
  }
}