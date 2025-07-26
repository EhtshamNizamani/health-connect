import 'package:equatable/equatable.dart';
import 'package:health_connect/core/data/entities/daily_availability_entity.dart';

class DoctorEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String specialization;
  final String bio;
  final int experience;
  final String photoUrl;
  final String clinicAddress;
  final int consultationFee;
  // The old 'availableSlots' is replaced with the new 'weeklyAvailability' map
  final Map<String, DailyAvailability> weeklyAvailability;

  const DoctorEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.specialization,
    required this.bio,
    required this.experience,
    required this.photoUrl,
    required this.clinicAddress,
    required this.consultationFee,
    required this.weeklyAvailability,
  });

  @override
  List<Object?> get props => [
    uid, name, email, specialization, bio, experience,
    photoUrl, clinicAddress, consultationFee, weeklyAvailability,
  ];
}