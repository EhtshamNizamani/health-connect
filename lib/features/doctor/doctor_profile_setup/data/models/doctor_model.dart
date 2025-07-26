// lib/features/doctor_profile_setup/data/models/doctor_model.dart
import 'package:health_connect/core/data/model/daily_availability_model.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

class DoctorModel {
  final String uid;
  final String name;
  final String email;
  final String specialization;
  final String bio;
  final int experience;
  final String photoUrl;
  final String clinicAddress;
  final int consultationFee;
  // The old list is replaced with the new map of MODELS
  final Map<String, DailyAvailabilityModel> weeklyAvailability;

  const DoctorModel({
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

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    // Logic to parse the nested weeklyAvailability map from Firestore
    final availabilityData = map['weeklyAvailability'] as Map<String, dynamic>? ?? {};
    final weeklyAvailability = availabilityData.map(
      (day, dailyData) => MapEntry(day, DailyAvailabilityModel.fromMap(dailyData)),
    );

    return DoctorModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      specialization: map['specialization'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      experience: map['experience'] as int? ?? 0,
      photoUrl: map['photoUrl'] as String? ?? '',
      clinicAddress: map['clinicAddress'] as String? ?? '',
      consultationFee: map['consultationFee'] as int? ?? 0,
      weeklyAvailability: weeklyAvailability,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'specialization': specialization,
      'bio': bio,
      'experience': experience,
      'photoUrl': photoUrl,
      'clinicAddress': clinicAddress,
      'consultationFee': consultationFee,
      // Convert the map of DailyAvailabilityModel back to a map of Maps for Firestore
      'weeklyAvailability': weeklyAvailability.map(
        (day, dailyModel) => MapEntry(day, dailyModel.toMap()),
      ),
    };
  }

  DoctorEntity toDomain() {
    return DoctorEntity(
      uid: uid,
      name: name,
      email: email,
      specialization: specialization,
      bio: bio,
      experience: experience,
      photoUrl: photoUrl,
      clinicAddress: clinicAddress,
      consultationFee: consultationFee,
      // Convert the map of Models to a map of Entities
      weeklyAvailability: weeklyAvailability.map(
        (day, dailyModel) => MapEntry(day, dailyModel.toDomain()),
      ),
    );
  }

  factory DoctorModel.fromEntity(DoctorEntity entity) {
    return DoctorModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      specialization: entity.specialization,
      bio: entity.bio,
      experience: entity.experience,
      photoUrl: entity.photoUrl,
      clinicAddress: entity.clinicAddress,
      consultationFee: entity.consultationFee,
      // Convert the map of Entities to a map of Models
      weeklyAvailability: entity.weeklyAvailability.map(
        (day, dailyEntity) => MapEntry(day, DailyAvailabilityModel.fromEntity(dailyEntity)),
      ),
    );
  }

  DoctorModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? specialization,
    String? bio,
    int? experience,
    String? photoUrl,
    String? clinicAddress,
    int? consultationFee,
    Map<String, DailyAvailabilityModel>? weeklyAvailability,
  }) {
    return DoctorModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      specialization: specialization ?? this.specialization,
      bio: bio ?? this.bio,
      experience: experience ?? this.experience,
      photoUrl: photoUrl ?? this.photoUrl,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      consultationFee: consultationFee ?? this.consultationFee,
      weeklyAvailability: weeklyAvailability ?? this.weeklyAvailability,
    );
  }
}