import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:health_connect/features/doctor/patient_records/domain/entity/patient_record_entity.dart';
import 'package:health_connect/features/doctor/patient_records/domain/usecase/get_patients_for_doctor_usecase.dart';
import 'patient_records_event.dart';
import 'patient_records_state.dart';

class PatientRecordsBloc extends Bloc<PatientRecordsEvent, PatientRecordsState> {
  final GetPatientsForDoctorUseCase _getPatientsUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  PatientRecordsBloc(this._getPatientsUseCase, this._getCurrentUserUseCase)
      : super(PatientRecordsInitial()) {
    on<FetchPatientRecords>(_onFetchPatientRecords);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<FilterChanged>(_onFilterChanged);
  }

  Future<void> _onFetchPatientRecords(
    FetchPatientRecords event,
    Emitter<PatientRecordsState> emit,
  ) async {
    emit(PatientRecordsLoading());
    final user = await _getCurrentUserUseCase();
    if (user == null) {
      emit(const PatientRecordsError("Doctor not authenticated."));
      return;
    }
    
    final result = await _getPatientsUseCase(user.id);
    
    result.fold(
      (failure) => emit(PatientRecordsError(failure.message)),
      (patients) {
        // Initially, the filtered list is the same as the full list.
        emit(PatientRecordsLoaded(
          allPatients: patients,
          filteredPatients: patients,
        ));
      },
    );
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<PatientRecordsState> emit,
  ) {
    if (state is PatientRecordsLoaded) {
      final currentState = state as PatientRecordsLoaded;
      final query = event.query.toLowerCase();
      
      if (query.isEmpty) {
        // If search is cleared, re-apply the last active filter.
        add(FilterChanged(currentState.activeFilter));
        return;
      }
      
      final filteredList = currentState.allPatients
          .where((record) => record.patient.name.toLowerCase().contains(query))
          .toList();
          
      emit(PatientRecordsLoaded(
        allPatients: currentState.allPatients,
        filteredPatients: filteredList,
        activeFilter: currentState.activeFilter,
      ));
    }
  }
  
  void _onFilterChanged(
    FilterChanged event,
    Emitter<PatientRecordsState> emit,
  ) {
    if (state is PatientRecordsLoaded) {
      final currentState = state as PatientRecordsLoaded;
      List<PatientRecordEntity> filteredList = List.from(currentState.allPatients);
      
      switch (event.filter) {
        case "Recently Active":
          filteredList.sort((a, b) => b.lastVisit!.compareTo(a.lastVisit!));
          break;
        case "A-Z":
          filteredList.sort((a, b) => a.patient.name.compareTo(b.patient.name));
          break;
        case "All":
        default:
          // No special sorting needed, or sort by default (e.g., last visit)
          filteredList.sort((a, b) => b.lastVisit!.compareTo(a.lastVisit!));
          break;
      }
      
      emit(PatientRecordsLoaded(
        allPatients: currentState.allPatients,
        filteredPatients: filteredList,
        activeFilter: event.filter,
      ));
    }
  }
}