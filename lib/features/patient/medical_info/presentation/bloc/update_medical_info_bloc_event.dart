
import 'package:equatable/equatable.dart';

abstract class UpdateMedicalInfoEvent extends Equatable {
  const UpdateMedicalInfoEvent();
  @override
  List<Object?> get props => [];
}

class UpdateInfoButtonPressed extends UpdateMedicalInfoEvent {
  final String? allergies;
  final String? chronicConditions;
  final String? age;
  final String? gender;

  const UpdateInfoButtonPressed({
    this.allergies,
    this.chronicConditions,
    this.age,
    this.gender,
  });

  @override
  List<Object?> get props => [allergies, chronicConditions, age, gender];
}