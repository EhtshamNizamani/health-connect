import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/data/entities/daily_availability_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/usecase/get_current_doctor_profile_usecase.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/usecase/save_doctor_usecase.dart';
import 'doctor_profile_setup_event.dart';
import 'doctor_profile_setup_state.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart' as profile;

class DoctorProfileSetupBloc
    extends Bloc<DoctorProfileSetupEvent, DoctorProfileSetupState> {
  final SaveDoctorProfileUseCase saveDoctorProfile;
  final GetCurrentDoctorProfileUseCase getCurrentDoctorProfileUsecase;
       final defaultAvailability = {
      'monday': const DailyAvailability(isWorking: false, slots: []),
      'tuesday': const DailyAvailability(isWorking: false, slots: []),
      'wednesday': const DailyAvailability(isWorking: false, slots: []),
      'thursday': const DailyAvailability(isWorking: false, slots: []),
      'friday': const DailyAvailability(isWorking: false, slots: []),
      'saturday': const DailyAvailability(isWorking: false, slots: []),
      'sunday': const DailyAvailability(isWorking: false, slots: []),
    };
  DoctorProfileSetupBloc(this.saveDoctorProfile, this.getCurrentDoctorProfileUsecase,)
    : super(DoctorProfileInitial()) {
    on<SubmitDoctorProfile>(_onSubmitProfile);
    on<GetCurrentDoctorProfile>(_onGetCurrentDoctorProfile);
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
        weeklyAvailability: defaultAvailability,
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

  Future<void> _onGetCurrentDoctorProfile(
    GetCurrentDoctorProfile event,
    Emitter<DoctorProfileSetupState> emit,
  ) async {
    emit(DoctorProfileLoading());
    try {
      final Either<profile.DoctorProfileFailure, DoctorEntity> result =
          await getCurrentDoctorProfileUsecase();
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
