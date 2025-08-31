import 'package:equatable/equatable.dart';
import 'prescription_item_entity.dart'; // Nayi entity ko import karein
import 'attached_file_entity.dart'; // Nayi entity ko import karein

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
  final List<AttachedFileEntity> attachedFiles; // Ab yeh List<Entity> hai

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

  AppointmentEntity copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    String? doctorName,
    String? patientName,
    String? doctorPhotoUrl,
    String? patientPhotoUrl,
    DateTime? appointmentDateTime,
    String? status,
    int? consultationFee,
    DateTime? createdAt,
    bool? isReviewed,
    bool? isReadByDoctor,
    bool? isReadByPatient,
    String? doctorNotes,
    List<PrescriptionItemEntity>? prescription,
    List<AttachedFileEntity>? attachedFiles,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      doctorName: doctorName ?? this.doctorName,
      patientName: patientName ?? this.patientName,
      doctorPhotoUrl: doctorPhotoUrl ?? this.doctorPhotoUrl,
      patientPhotoUrl: patientPhotoUrl ?? this.patientPhotoUrl,
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      status: status ?? this.status,
      consultationFee: consultationFee ?? this.consultationFee,
      createdAt: createdAt ?? this.createdAt,
      isReviewed: isReviewed ?? this.isReviewed,
      isReadByDoctor: isReadByDoctor ?? this.isReadByDoctor,
      isReadByPatient: isReadByPatient ?? this.isReadByPatient,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      prescription: prescription ?? this.prescription,
      attachedFiles: attachedFiles ?? this.attachedFiles,
    );
  }
}
