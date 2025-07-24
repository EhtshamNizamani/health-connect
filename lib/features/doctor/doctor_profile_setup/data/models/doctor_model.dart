// lib/features/doctor_profile_setup/data/models/doctor_model.dart
import 'package:health_connect/features/doctor/doctor_profile_setup/data/models/available_slot.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

// This class no longer extends DoctorEntity
class DoctorModel {
  final String uid;
  final String name;
  final String email;
  final String specialization;
  final String bio;
  final int experience;
  final List<AvailableSlotModel> availableSlots; // Note: This is a list of MODELS
  final String photoUrl;
  final String clinicAddress;
  final int consultationFee;

  const DoctorModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.specialization,
    required this.bio,
    required this.experience,
    required this.availableSlots,
    required this.photoUrl,
    required this.clinicAddress,
    required this.consultationFee,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
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
      // Create a list of AvailableSlotModel from the map data
      availableSlots: (map['availableSlots'] as List<dynamic>?)
          ?.map((slotMap) => AvailableSlotModel.fromMap(slotMap as Map<String, dynamic>))
          .toList() ?? [],
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
      // Convert the list of AvailableSlotModel back to a list of maps
      'availableSlots': availableSlots.map((slot) => slot.toMap()).toList(),
    };
  }

  // THE MOST IMPORTANT METHOD:
  // Converts this Data Model into a pure Domain Entity
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
      // Convert the list of models to a list of entities by calling .toDomain() on each
      availableSlots: availableSlots.map((slotModel) => slotModel.toDomain()).toList(),
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
    // We also need to convert the list of entities to a list of models
    availableSlots: entity.availableSlots
        .map((slotEntity) => AvailableSlotModel.fromEntity(slotEntity))
        .toList(),
  );
}

DoctorModel copyWith({
  String? uid,
  String? name,
  String? email,
  String? specialization,
  String? bio,
  int? experience,
  List<AvailableSlotModel>? availableSlots, 
  String? photoUrl,
  String? clinicAddress,
  int? consultationFee,
}) {
  return DoctorModel(
    uid: uid ?? this.uid,
    name: name ?? this.name,
    email: email ?? this.email,
    specialization: specialization ?? this.specialization,
    bio: bio ?? this.bio,
    experience: experience ?? this.experience,
    // Now the types match perfectly.
    availableSlots: availableSlots ?? this.availableSlots,
    photoUrl: photoUrl ?? this.photoUrl,
    clinicAddress: clinicAddress ?? this.clinicAddress,
    consultationFee: consultationFee ?? this.consultationFee,
  );
}
}