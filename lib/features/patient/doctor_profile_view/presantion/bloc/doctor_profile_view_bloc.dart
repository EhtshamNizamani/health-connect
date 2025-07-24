import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/patient/doctor_profile_view/domain/usecase/get_doctor_by_id_usecase.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_bloc_event.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_bloc_state%202.dart';

class DoctorProfileViewBloc extends Bloc<DoctorProfileViewEvent, DoctorProfileViewState> {
  final GetDoctorByIdUseCase _getDoctorByIdUseCase;

  DoctorProfileViewBloc(this._getDoctorByIdUseCase) : super(DoctorProfileInitial()) {
    on<FetchDoctorDetails>((event, emit) async {
      emit(DoctorProfileLoading());
      final result = await _getDoctorByIdUseCase(event.doctorId);
      
      result.fold(
        (failure) => emit(DoctorProfileError(failure.message)),
        (doctor) => emit(DoctorProfileLoaded(doctor)),
      );
    });
  }
}