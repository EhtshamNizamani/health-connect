import 'package:equatable/equatable.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';


abstract class DoctorListState extends Equatable {
  const DoctorListState();
  @override
  List<Object?> get props => [];
}

class DoctorListInitial extends DoctorListState {}
class DoctorListLoading extends DoctorListState {}
class DoctorListError extends DoctorListState {
  final String message;
  const DoctorListError(this.message);
  @override
  List<Object?> get props => [message];
}

// <<< --- UPDATE THIS STATE ---
class DoctorListLoaded extends DoctorListState {
  // This will hold the complete list of doctors fetched from Firestore
  final List<DoctorEntity> allDoctors;
  // This will hold the list of doctors to be displayed (after filtering)
  final List<DoctorEntity> filteredDoctors;

  const DoctorListLoaded({
    required this.allDoctors,
    required this.filteredDoctors,
  });

  @override
  List<Object?> get props => [allDoctors, filteredDoctors];

  // Helper method to create a new state with updated filters
  DoctorListLoaded copyWith({
    List<DoctorEntity>? allDoctors,
    List<DoctorEntity>? filteredDoctors,
  }) {
    return DoctorListLoaded(
      allDoctors: allDoctors ?? this.allDoctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
    );
  }
}