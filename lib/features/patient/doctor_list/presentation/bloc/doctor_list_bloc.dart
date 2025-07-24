import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/patient/doctor_list/domain/usecases/get_doctors_usecase.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_bloc_state.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_event.dart';

class DoctorListBloc extends Bloc<DoctorListEvent, DoctorListState> {
  final GetDoctorsUseCase _getDoctorsUseCase;

  DoctorListBloc(this._getDoctorsUseCase) : super(DoctorListInitial()) {
    on<FetchDoctorsList>((event, emit) async {
      // Get the current list of doctors if it exists
      final currentDoctors = state.doctors;
      
      // Emit Loading state, but pass the current list so the UI doesn't flash
      emit(DoctorListLoading(doctors: currentDoctors));
      
      final result = await _getDoctorsUseCase();
      
      result.fold(
        (failure) => emit(DoctorListError(failure.message)),
        (newDoctors) => emit(DoctorListLoaded(doctors: newDoctors)),
      );
    });
  }
}