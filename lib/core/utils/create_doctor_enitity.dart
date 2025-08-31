 import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

/// Creates a [DoctorEntity] from a [UserEntity] to pass to other screens.
  DoctorEntity createDoctorEntity(UserEntity currentUser) {
    // This is a placeholder conversion. A better approach would be a factory
    // constructor or having the full DoctorEntity in the AuthBloc state.
    return DoctorEntity(
      uid: currentUser.id,
      name: currentUser.name,
      email: currentUser.email,
      photoUrl: currentUser.photoUrl ?? '',
      specialization: '',
      bio: '',
      experience: 0,
      clinicAddress: '',
      consultationFee: 0,
      weeklyAvailability: {},
    );
  }