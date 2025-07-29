import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/usecase/get_current_doctor_profile_usecase.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/domain/usecase/doctor_profile_update_usecase.dart';

import 'doctor_profile_update_event.dart';
import 'doctor_profile_update_state.dart';

class DoctorProfileUpdateBloc
    extends Bloc<DoctorProfileUpdateEvent, DoctorProfileUpdateState> {
  final GetCurrentDoctorProfileUseCase _getCurrentDoctorProfileUseCase;
  final DoctroProfileUpdateUseCase _doctroProfileUpdateUseCase;

  DoctorProfileUpdateBloc(
    this._getCurrentDoctorProfileUseCase,
    this._doctroProfileUpdateUseCase,
  ) : super(DoctorProfileUpdateInitial()) {
    on<FetchDoctorProfileForUpdate>(_onFetchProfile);
    on<SubmitProfileUpdate>(_onUpdateProfile);
  }

  Future<void> _onFetchProfile(
    FetchDoctorProfileForUpdate event,
    Emitter<DoctorProfileUpdateState> emit,
  ) async {
    emit(DoctorProfileUpdateLoading());
    final result = await _getCurrentDoctorProfileUseCase();
    result.fold(
      (failure) => emit(DoctorProfileUpdateFailure(failure.message)),
      (doctor) => emit(DoctorProfileUpdateLoaded(doctor)),
    );
  }

  Future<void> _onUpdateProfile(
    SubmitProfileUpdate event,
    Emitter<DoctorProfileUpdateState> emit,
  ) async {
    emit(DoctorProfileUpdating());

    final doctorToUpdate = DoctorEntity(
      uid: event.uid,
      name: event.name,
      email: '', // Email is usually not updatable, get from auth if needed
      specialization: event.specialization,
      bio: event.bio,
      experience: event.experience,
      clinicAddress: event.clinicAddress,
      consultationFee: event.consultationFee,
      photoUrl: event.existingPhotoUrl,
      weeklyAvailability: {}, // Handle availability separately if needed
    );

    final result = await _doctroProfileUpdateUseCase(
      doctorToUpdate,
      event.newPhotoFile,
    );

    result.fold(
      (failure) => emit(DoctorProfileUpdateFailure(failure.message)),
      (_) => emit(DoctorProfileUpdateSuccess()),
    );
  }
}
