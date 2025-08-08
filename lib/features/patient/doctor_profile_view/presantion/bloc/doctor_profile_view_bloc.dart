import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/patient/doctor_profile_view/domain/usecase/get_available_slots_usecase.dart';
import 'package:health_connect/features/patient/doctor_profile_view/domain/usecase/get_doctor_by_id_usecase.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_event.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_state.dart';

class DoctorProfileViewBloc extends Bloc<DoctorProfileViewEvent, DoctorProfileViewState> {
  final GetDoctorByIdUseCase _getDoctorByIdUseCase;
  final GetAvailableSlotsUseCase _getAvailableSlotsUseCase;

  DoctorProfileViewBloc(this._getDoctorByIdUseCase, this._getAvailableSlotsUseCase) 
      : super(DoctorProfileViewInitial()) {
    on<FetchDoctorDetailsViewEvent>(_onFetchDoctorDetails);
    on<FetchAvailableSlotsViewEvent>(_onFetchAvailableSlots);
    on<TimeSlotSelected>(_onTimeSlotSelected);
  }

  Future<void> _onFetchDoctorDetails(
    FetchDoctorDetailsViewEvent event,
    Emitter<DoctorProfileViewState> emit,
  ) async {
    emit(DoctorProfileViewLoading());
    final result = await _getDoctorByIdUseCase(event.doctorId);
    result.fold(
      (failure) => emit(DoctorProfileViewError(failure.message)),
      (doctor) {
        emit(DoctorProfileViewLoaded(doctor: doctor));
        add(FetchAvailableSlotsViewEvent(doctorId: doctor.uid, date: DateTime.now()));
      },
    );
  }

  Future<void> _onFetchAvailableSlots(
    FetchAvailableSlotsViewEvent event,
    Emitter<DoctorProfileViewState> emit,
  ) async {
    if (state is DoctorProfileViewLoaded) {
      final currentState = state as DoctorProfileViewLoaded;
      emit(currentState.copyWith(areSlotsLoading: true, availableSlots: null, clearSlotsError: true));
      
      final result = await _getAvailableSlotsUseCase(event.doctorId, event.date);
      
      result.fold(
        (failure) {
          emit(currentState.copyWith(areSlotsLoading: false, slotsError: failure.message));
        },
        (slots) {
          print("test slots ${slots}");
          emit(currentState.copyWith(areSlotsLoading: false, availableSlots: slots));
        },
      );
    }
  }

  Future<void> _onTimeSlotSelected(TimeSlotSelected event, Emitter<DoctorProfileViewState> emit)async{
    if(state is DoctorProfileViewLoaded){
      final currentState = state as DoctorProfileViewLoaded;
      emit(currentState.copyWith(selectedSlot: event.slot));
    }
  }
}