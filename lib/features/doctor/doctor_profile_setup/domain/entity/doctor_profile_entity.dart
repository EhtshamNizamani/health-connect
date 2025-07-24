import 'package:equatable/equatable.dart';
import 'available_slot.dart'; 

class DoctorEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String specialization;
  final String bio;
  final int experience;
  final List<AvailableSlot> availableSlots; // Note: This is a list of ENTITIES
  final String photoUrl;
  final String clinicAddress;
  final int consultationFee;

  const DoctorEntity({
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

  @override
  List<Object?> get props => [
    uid, name, email, specialization, bio, experience,
    availableSlots, photoUrl, clinicAddress, consultationFee,
  ];
}