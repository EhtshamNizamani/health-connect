import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/available_slot.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/usecase/save_doctor_usecase.dart';
import 'doctor_profile_setup_event.dart';
import 'doctor_profile_setup_state.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart' as profile;

class DoctorProfileSetupBloc
    extends Bloc<DoctorProfileSetupEvent, DoctorProfileSetupState> {
  final SaveDoctorProfileUseCase saveDoctorProfile;

  DoctorProfileSetupBloc(this.saveDoctorProfile)
    : super(DoctorProfileInitial()) {
    on<SubmitDoctorProfile>(_onSubmitProfile);
    on<GetCurrentDoctorProfile>(_onGetCurrentDoctorProfile);
    on<UpdateDoctorProfile>(_onUpdateDoctorProfile);
  }

  Future<void> _onSubmitProfile(
    SubmitDoctorProfile event,
    Emitter<DoctorProfileSetupState> emit,
  ) async {
    emit(DoctorProfileLoading());
    try {
      final doctor = DoctorEntity(
        uid: "", // Ye Repository mein set hoga
        name: event.name,
        email: event.email,
        specialization: event.specialization,
        bio: event.bio,
        experience: event.experience,
        clinicAddress: event.clinicAddress,
        consultationFee: event.consultationFee,
        photoUrl: "", // Ye bhi Repository mein set hoga
        availableSlots: [
          // SAHI: Ab hum saaf suthra 'AvailableSlot' Entity use kar rahe hain
          AvailableSlot(startTime: event.startTime, endTime: event.endTime),
        ],
      );

      // SaveDoctorProfileUseCase ko DoctorEntity aur File chahiye
      final Either<profile.Failure, void> result =
          await saveDoctorProfile.saveDoctorProfile(doctor, event.photoFile);
      result.fold(
        (failure) {
          emit(DoctorProfileFailure(failure.message));
        },
        (_) {
          emit(DoctorProfileSuccess());
        },
      );
    } catch (e) {
      emit(DoctorProfileFailure(e.toString()));
    }
  }

  Future<void> _onUpdateDoctorProfile(UpdateDoctorProfile event, Emitter<DoctorProfileSetupState> emit)async{
    emit(DoctorProfileLoading());
    try{
        final doctorToUpdate = DoctorEntity(
    uid: event.uid, // Update ke waqt UID pata honi chahiye
    name: event.name,
    email: event.email, // Ye bhi UI ya auth se aayega
    specialization: event.specialization,
    bio: event.bio,
    experience: event.experience,
    clinicAddress: event.clinicAddress,
    consultationFee: event.consultationFee,
    photoUrl: event.existingPhotoUrl, // Purani photo ka URL pass karein
    availableSlots: [
      AvailableSlot(startTime: event.startTime, endTime: event.endTime),
    ],
  );

      final Either<profile.Failure, DoctorEntity> result = await saveDoctorProfile.updateDoctorProfile(doctorToUpdate, event.newPhotoFile);
    result.fold((l)=> emit(DoctorProfileFailure(l.message)), 
      (r) => emit(DoctorProfileLoaded(r)));
    }catch(e){
      emit(DoctorProfileFailure( e.toString()));
    }
  }

  Future<void> _onGetCurrentDoctorProfile(
    GetCurrentDoctorProfile event,
    Emitter<DoctorProfileSetupState> emit,
  ) async {
    emit(DoctorProfileLoading());
    try {
      final Either<profile.DoctorProfileFailure, DoctorEntity> result =
          await saveDoctorProfile.getCurrentDoctorProfile();
      result.fold(
        (failure) {
          emit(DoctorProfileFailure(failure.message));
        },
        (doctor) {
          emit(DoctorProfileLoaded(doctor));
        },
      );
    } catch (e) {
      emit(DoctorProfileFailure(e.toString()));
    }
    
  }

  
}
