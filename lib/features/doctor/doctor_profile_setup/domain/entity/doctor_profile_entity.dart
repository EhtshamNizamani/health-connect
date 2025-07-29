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
  final int reviewCount;
  final double totalRating;
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
    this.totalRating = 0.0, // Add default values
    this.reviewCount = 0,
  });
  // Helper getter for easy calculation in the UI
  double get averageRating {
    if (reviewCount == 0) {
      return 0.0;
    }
    return totalRating / reviewCount;
  }

  @override
  List<Object?> get props => [
    uid,
    name,
    email,
    specialization,
    bio,
    experience,
    photoUrl,
    clinicAddress,
    consultationFee,
    weeklyAvailability,
    totalRating,
    reviewCount,
  ];
}
