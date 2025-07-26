import 'package:equatable/equatable.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

abstract class DoctorProfileViewState extends Equatable {
  const DoctorProfileViewState();
  @override
  List<Object?> get props => [];
}

class DoctorProfileViewInitial extends DoctorProfileViewState {}
class DoctorProfileViewLoading extends DoctorProfileViewState {}
class DoctorProfileViewError extends DoctorProfileViewState {
  final String message;
  const DoctorProfileViewError(this.message);
  @override
  List<Object?> get props => [message];
}

class DoctorProfileViewLoaded extends DoctorProfileViewState {
  final DoctorEntity doctor;
  final List<DateTime>? availableSlots;
  final bool areSlotsLoading;
  final String? slotsError;

  const DoctorProfileViewLoaded({
    required this.doctor,
    this.availableSlots,
    this.areSlotsLoading = false,
    this.slotsError,
  });
  
  DoctorProfileViewLoaded copyWith({
    DoctorEntity? doctor,
    List<DateTime>? availableSlots,
    bool? areSlotsLoading,
    String? slotsError,
    bool clearSlotsError = false,
  }) {
    return DoctorProfileViewLoaded(
      doctor: doctor ?? this.doctor,
      availableSlots: availableSlots ?? this.availableSlots,
      areSlotsLoading: areSlotsLoading ?? this.areSlotsLoading,
      slotsError: clearSlotsError ? null : slotsError ?? this.slotsError,
    );
  }
  
  @override
  List<Object?> get props => [doctor, availableSlots, areSlotsLoading, slotsError];
}