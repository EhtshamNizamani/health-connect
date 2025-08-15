import 'package:equatable/equatable.dart';
import 'prescription_item_entity.dart'; // Nayi entity ko import karein
import 'attached_file_entity.dart';   // Nayi entity ko import karein

class AppointmentEntity extends Equatable {
  final String id;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final String doctorPhotoUrl;
  final String patientPhotoUrl;
  final DateTime appointmentDateTime;
  final String status;
  final int consultationFee;
  final DateTime createdAt;
  final bool isReviewed;
  final bool isReadByDoctor;
  final bool isReadByPatient;

  // --- Updated Fields ---
  final String? doctorNotes;
  final List<PrescriptionItemEntity> prescription; // Ab yeh List<Entity> hai
  final List<AttachedFileEntity> attachedFiles;   // Ab yeh List<Entity> hai

  const AppointmentEntity({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.doctorName,
    required this.patientName,
    required this.doctorPhotoUrl,
    required this.patientPhotoUrl,
    required this.appointmentDateTime,
    required this.status,
    required this.consultationFee,
    required this.isReadByDoctor,
    required this.createdAt,
    required this.isReadByPatient,
    this.isReviewed = false,
    this.doctorNotes,
    this.prescription = const [], // Default to an empty list of entities
    this.attachedFiles = const [], // Default to an empty list of entities
  });

  @override
  List<Object?> get props => [
        id,
        doctorId,
        patientId,
        appointmentDateTime,
        status,
        doctorNotes,
        prescription,
        attachedFiles,
      ];
}