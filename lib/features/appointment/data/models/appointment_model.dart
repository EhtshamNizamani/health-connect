import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/domain/entities/prescription_item_entity.dart';
import 'package:health_connect/features/appointment/domain/entities/attached_file_entity.dart';

class AppointmentModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final String doctorPhotoUrl;
  final String patientPhotoUrl;
  final Timestamp appointmentDateTime;
  final String status;
  final int consultationFee;
  final Timestamp createdAt;
  final bool isReviewed;
  final bool isReadByDoctor;
  final bool isReadByPatient;
  final String? doctorNotes;
  final List<Map<String, dynamic>> prescription;
  final List<Map<String, dynamic>> attachedFiles;

  const AppointmentModel({
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
    required this.createdAt,
    required this.isReviewed,
    required this.isReadByPatient,
    required this.isReadByDoctor,
    this.doctorNotes,
    this.prescription = const [],
    this.attachedFiles = const [],
  });

  factory AppointmentModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      doctorId: data['doctorId'] as String? ?? '',
      patientId: data['patientId'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      doctorPhotoUrl: data['doctorPhotoUrl'] as String? ?? '',
      patientPhotoUrl: data['patientPhotoUrl'] as String? ?? '',
      appointmentDateTime: data['appointmentDateTime'] as Timestamp? ?? Timestamp.now(),
      status: data['status'] as String? ?? 'pending',
      consultationFee: data['consultationFee'] as int? ?? 0,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      isReviewed: data['isReviewed'] as bool? ?? false,
      isReadByDoctor: data['isReadByDoctor'] as bool? ?? false,
      isReadByPatient: data['isReadByPatient'] as bool? ?? false,
      doctorNotes: data['doctorNotes'] as String?,
      prescription: List<Map<String, dynamic>>.from(data['prescription'] as List? ?? []),
      attachedFiles: List<Map<String, dynamic>>.from(data['attachedFiles'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'doctorName': doctorName,
      'patientName': patientName,
      'doctorPhotoUrl': doctorPhotoUrl,
      'patientPhotoUrl': patientPhotoUrl,
      'appointmentDateTime': appointmentDateTime,
      'status': status,
      'consultationFee': consultationFee,
      'createdAt': createdAt,
      'isReviewed': isReviewed,
      'isReadByDoctor': isReadByDoctor,
      'isReadByPatient': isReadByPatient,
      'doctorNotes': doctorNotes,
      'prescription': prescription,
      'attachedFiles': attachedFiles,
    };
  }

  AppointmentEntity toDomain() {
    return AppointmentEntity(
      id: id,
      doctorId: doctorId,
      patientId: patientId,
      doctorName: doctorName,
      patientName: patientName,
      doctorPhotoUrl: doctorPhotoUrl,
      patientPhotoUrl: patientPhotoUrl,
      appointmentDateTime: appointmentDateTime.toDate(),
      status: status,
      consultationFee: consultationFee,
      createdAt: createdAt.toDate(),
      isReviewed: isReviewed,
      isReadByDoctor: isReadByDoctor,
      isReadByPatient: isReadByPatient,
      doctorNotes: doctorNotes,
      prescription: prescription.map((item) => PrescriptionItemEntity(
        medicine: item['medicine'] as String? ?? '',
        dosage: item['dosage'] as String? ?? '',
        instructions: item['instructions'] as String?, // Added instructions
      )).toList(),
      attachedFiles: attachedFiles.map((item) => AttachedFileEntity(
        fileName: item['fileName'] as String? ?? '',
        url: item['url'] as String? ?? '',
      )).toList(),
    );
  }

  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id,
      doctorId: entity.doctorId,
      patientId: entity.patientId,
      doctorName: entity.doctorName,
      patientName: entity.patientName,
      doctorPhotoUrl: entity.doctorPhotoUrl,
      patientPhotoUrl: entity.patientPhotoUrl,
      appointmentDateTime: Timestamp.fromDate(entity.appointmentDateTime),
      status: entity.status,
      consultationFee: entity.consultationFee,
      createdAt: Timestamp.fromDate(entity.createdAt),
      isReviewed: entity.isReviewed,
      isReadByDoctor: entity.isReadByDoctor,
      isReadByPatient: entity.isReadByPatient,
      doctorNotes: entity.doctorNotes,
      prescription: entity.prescription.map((item) => {
        'medicine': item.medicine,
        'dosage': item.dosage,
        'instructions': item.instructions, // Added instructions
      }).toList(),
      attachedFiles: entity.attachedFiles.map((item) => {
        'fileName': item.fileName,
        'url': item.url,
      }).toList(),
    );
  }
}