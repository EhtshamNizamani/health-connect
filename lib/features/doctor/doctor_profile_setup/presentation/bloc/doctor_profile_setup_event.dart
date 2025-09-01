// lib/features/doctor_profile/presentation/bloc/doctor_profile_setup_event.dart

import 'dart:io';
import 'package:equatable/equatable.dart';

class DoctorProfileSetupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitDoctorProfile extends DoctorProfileSetupEvent {
  final String name;
  final String email;
  final String specialization;
  final String bio;
  final int experience;
  final String clinicAddress;
  final int consultationFee;
  final File? photoFile;

  SubmitDoctorProfile({
    required this.name,
    required this.email,
    required this.specialization,
    required this.bio,
    required this.experience,
    required this.clinicAddress,
    required this.consultationFee,
    required this.photoFile,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        specialization,
        bio,
        experience,
        clinicAddress,
        consultationFee,
        photoFile,
      ];
}

class GetCurrentDoctorProfile extends DoctorProfileSetupEvent{}
class UpdateDoctorProfile extends DoctorProfileSetupEvent{
  final String uid;
  final String name;
  final String email;
  final String specialization;
  final String bio;
  final int experience;
  final String clinicAddress;
  final int consultationFee;
  final String existingPhotoUrl;
  final File? photoFile;
  final File? newPhotoFile;
  UpdateDoctorProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.specialization,
    required this.bio,
    required this.experience,
    required this.clinicAddress,
    required this.consultationFee,
    required this.existingPhotoUrl,
    required this.photoFile,
    required this.newPhotoFile,
  });

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        specialization,
        bio,
        experience,
        clinicAddress,
        consultationFee,
        existingPhotoUrl,
        photoFile,
        newPhotoFile,
      ];
}
