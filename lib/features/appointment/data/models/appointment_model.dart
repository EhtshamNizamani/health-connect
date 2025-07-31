import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
// lib/features/appointment/data/models/appointment_model.dart

class AppointmentModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final String doctorPhotoUrl;
  final Timestamp appointmentDateTime;
  final String status;
  final int consultationFee;
  final Timestamp createdAt;
  final bool isReviewed; // <<<--- NEW FIELD ADDED

  const AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.doctorName,
    required this.patientName,
    required this.doctorPhotoUrl,
    required this.appointmentDateTime,
    required this.status,
    required this.consultationFee,
    required this.createdAt,
    required this.isReviewed, // <<<--- ADDED TO CONSTRUCTOR
  });

  // --- METHODS TO INTERACT WITH DATA SOURCE (FIRESTORE) ---

  factory AppointmentModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      doctorId: data['doctorId'] as String? ?? '',
      patientId: data['patientId'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      doctorPhotoUrl: data['doctorPhotoUrl'] as String? ?? '',
      appointmentDateTime: data['appointmentDateTime'] as Timestamp? ?? Timestamp.now(),
      status: data['status'] as String? ?? 'pending',
      consultationFee: data['consultationFee'] as int? ?? 0,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      // Read the 'isReviewed' field. Default to 'false' if it doesn't exist.
      isReviewed: data['isReviewed'] as bool? ?? false, // <<<--- LOGIC ADDED
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'doctorName': doctorName,
      'patientName': patientName,
      'doctorPhotoUrl': doctorPhotoUrl,
      'appointmentDateTime': appointmentDateTime,
      'status': status,
      'consultationFee': consultationFee,
      'createdAt': createdAt,
      'isReviewed': isReviewed, // <<<--- FIELD ADDED TO MAP
    };
  }

  // --- METHODS TO CONVERT BETWEEN DOMAIN AND DATA LAYERS ---

  AppointmentEntity toDomain() {
    return AppointmentEntity(
      id: id,
      doctorId: doctorId,
      patientId: patientId,
      doctorName: doctorName,
      patientName: patientName,
      doctorPhotoUrl: doctorPhotoUrl,
      appointmentDateTime: appointmentDateTime.toDate(),
      status: status,
      consultationFee: consultationFee,
      createdAt: createdAt.toDate(),
      isReviewed: isReviewed, // <<<--- FIELD ADDED
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
      appointmentDateTime: Timestamp.fromDate(entity.appointmentDateTime),
      status: entity.status,
      consultationFee: entity.consultationFee,
      createdAt: Timestamp.fromDate(entity.createdAt),
      isReviewed: entity.isReviewed, // <<<--- FIELD ADDED
    );
  }
}