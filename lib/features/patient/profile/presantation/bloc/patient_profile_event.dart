import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class PatientProfileEvent extends Equatable {
  const PatientProfileEvent();
  @override
  List<Object?> get props => [];
}

class UpdateProfileButtonPressed extends PatientProfileEvent {
  final String name;
  final File? photoFile;
  final String? allergies;
  final String? chronicConditions;
  final String? age;
  final String? gender;

  const UpdateProfileButtonPressed({
    required this.name,
    this.photoFile,
    this.allergies,
    this.chronicConditions,
    this.age,
    this.gender,
  });
  
  @override
  List<Object?> get props => [name, photoFile, allergies, chronicConditions, age, gender];
}