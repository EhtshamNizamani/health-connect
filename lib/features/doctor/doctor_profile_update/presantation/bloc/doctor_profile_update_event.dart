import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class DoctorProfileUpdateEvent extends Equatable {
  const DoctorProfileUpdateEvent();
  @override
  List<Object?> get props => [];
}

// Event to fetch the doctor's current data
class FetchDoctorProfileForUpdate extends DoctorProfileUpdateEvent {}

// Event to submit the updated data
class SubmitProfileUpdate extends DoctorProfileUpdateEvent {
  final String uid;
  final String name;
  final String specialization;
  final String bio;
  final int experience;
  final String clinicAddress;
  final int consultationFee;
  final String existingPhotoUrl; // Needed for the repository
  final File? newPhotoFile;     // The new image, if any

  const SubmitProfileUpdate({
    required this.uid,
    required this.name,
    required this.specialization,
    required this.bio,
    required this.experience,
    required this.clinicAddress,
    required this.consultationFee,
    required this.existingPhotoUrl,
    this.newPhotoFile,
  });

  @override
  List<Object?> get props => [uid, name, bio, newPhotoFile];
}