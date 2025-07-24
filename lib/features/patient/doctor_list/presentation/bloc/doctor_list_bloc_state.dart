import 'package:equatable/equatable.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

import 'package:equatable/equatable.dart';

abstract class DoctorListState extends Equatable {
  // Add the property to the base class with a default empty list
  final List<DoctorEntity> doctors;
  
  const DoctorListState({this.doctors = const []});
  
  @override
  List<Object?> get props => [doctors];
}

class DoctorListInitial extends DoctorListState {}

class DoctorListLoading extends DoctorListState {
  // Use super constructor to pass the list
  const DoctorListLoading({super.doctors});
}

class DoctorListLoaded extends DoctorListState {
  // Use super constructor to pass the list
  const DoctorListLoaded({required List<DoctorEntity> doctors}) : super(doctors: doctors);
}

class DoctorListError extends DoctorListState {
  final String message;
  const DoctorListError(this.message);
  
  @override
  List<Object?> get props => [message];
}