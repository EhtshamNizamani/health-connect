import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/patient/doctor_list/domain/usecases/get_doctors_usecase.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_state.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_event.dart';

class DoctorListBloc extends Bloc<DoctorListEvent, DoctorListState> {
  final GetDoctorsUseCase _getDoctorsUseCase;

  DoctorListBloc(this._getDoctorsUseCase) : super(DoctorListInitial()) {
    on<FetchDoctorsList>(_onFetchDoctorsList);
    on<SearchQueryChanged>(_onSearchQueryChanged); // Register the new handler
  }

  Future<void> _onFetchDoctorsList(
    FetchDoctorsList event,
    Emitter<DoctorListState> emit,
  ) async {
    emit(DoctorListLoading());
    final result = await _getDoctorsUseCase();
    result.fold(
      (failure) => emit(DoctorListError(failure.message)),
      (doctors) {
        // When we first load, the filtered list is the same as the full list
        emit(DoctorListLoaded(allDoctors: doctors, filteredDoctors: doctors));
      },
    );
  }

  // <<< --- NEW EVENT HANDLER ---
  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<DoctorListState> emit,
  ) {
    // We only perform a search if the current state is DoctorListLoaded
    final currentState = state;
    if (currentState is DoctorListLoaded) {
      final query = event.query.toLowerCase();
      
      // If the search query is empty, show all doctors
      if (query.isEmpty) {
        emit(currentState.copyWith(filteredDoctors: currentState.allDoctors));
        return;
      }
      
      // Otherwise, filter the 'allDoctors' list
      final filteredList = currentState.allDoctors.where((doctor) {
        final doctorName = doctor.name.toLowerCase();
        final specialization = doctor.specialization.toLowerCase();
        // Search in both name and specialization
        return doctorName.contains(query) || specialization.contains(query);
      }).toList();
      
      // Emit a new state with the updated filtered list
      emit(currentState.copyWith(filteredDoctors: filteredList));
    }
  }
}