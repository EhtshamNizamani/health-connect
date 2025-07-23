// lib/features/doctor_profile_setup/data/models/doctor_model.dart
import 'package:health_connect/features/doctor/doctor_profile_setup/data/models/available_slot.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/available_slot.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_entity.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.specialization,
    required super.bio,
    required super.experience,
    required super.availableSlots,
    required super.photoUrl,
    required super.clinicAddress,
    required super.consultationFee,
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
      // SAHI: map ki list ko Model ki list mein convert karna
      availableSlots: (map['availableSlots'] as List<dynamic>?)
          ?.map((slotMap) => AvailableSlotModel.fromMap(slotMap as Map<String, dynamic>))
          .toList() ?? [],
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
      // SAHI: Entity ki list ko Model ki list mein convert karna (agar zaroorat ho)
      // Lekin yahan types compatible hain, to direct pass kar sakte hain
      availableSlots: entity.availableSlots,
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
      // SAHI: availableSlots (jo ek List<AvailableSlot> hai)
      // uske har item ko pehle Model banakar phir .toMap() call karna
      'availableSlots': availableSlots
          .map((slot) => AvailableSlotModel.fromEntity(slot).toMap())
          .toList(),
    };
  }

  DoctorModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? specialization,
    String? bio,
    int? experience,
    List<AvailableSlot>? availableSlots, // SAHI: Type ab DoctorEntity se match karta hai
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
      availableSlots: availableSlots ?? this.availableSlots,
      photoUrl: photoUrl ?? this.photoUrl,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      consultationFee: consultationFee ?? this.consultationFee,
    );
  }
}