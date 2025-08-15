import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/doctor/appointment_detail/domain/usecase/get_appointment_details_usecase.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/bloc/appointment_details_event.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/bloc/appointment_details_state.dart';

class AppointmentDetailBloc extends Bloc<AppointmentDetailEvent, AppointmentDetailState> {
  final GetAppointmentDetailsUseCase _getAppointmentDetailsUseCase;

  AppointmentDetailBloc(this._getAppointmentDetailsUseCase) : super(AppointmentDetailInitial()) {
    on<FetchAppointmentDetails>(_onFetchAppointmentDetails);
  }

  Future<void> _onFetchAppointmentDetails(
    FetchAppointmentDetails event,
    Emitter<AppointmentDetailState> emit,
  ) async {
    emit(AppointmentDetailLoading());
    
    final result = await _getAppointmentDetailsUseCase(event.appointmentId);
    
    result.fold(
      (failure) => emit(AppointmentDetailError(failure.message)),
      (details) => emit(AppointmentDetailLoaded(details)),
    );
  }
}