
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/doctor/patient_details/domain/usecases/get_patient_details_usecase.dart';
import 'package:health_connect/features/doctor/patient_details/presantation/bloc/patient_details_event.dart';
import 'package:health_connect/features/doctor/patient_details/presantation/bloc/patient_details_state.dart';

class PatientDetailBloc extends Bloc<PatientDetailEvent, PatientDetailState> {
  final GetPatientDetailsUseCase _getPatientDetailsUseCase;

  PatientDetailBloc(this._getPatientDetailsUseCase) : super(PatientDetailInitial()) {
    on<FetchPatientDetails>(_onFetchPatientDetails);
  }

  Future<void> _onFetchPatientDetails(
    FetchPatientDetails event,
    Emitter<PatientDetailState> emit,
  ) async {
    emit(PatientDetailLoading());
    final result = await _getPatientDetailsUseCase(event.patientId);
    result.fold(
      (failure) => emit(PatientDetailError(failure.message)),
      (details) => emit(PatientDetailLoaded(details)),
    );
  }
}