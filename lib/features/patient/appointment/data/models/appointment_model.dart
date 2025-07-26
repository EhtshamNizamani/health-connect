import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/patient/appointment/domain/entities/appointment_entity.dart';

class AppointmentModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final String doctorPhotoUrl;
  final Timestamp appointmentDateTime; // Using Firestore Timestamp for data layer
  final String status;
  final int consultationFee;
  final Timestamp createdAt;           // Using Firestore Timestamp for data layer

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
  });

  // ---------------------------------------------------------------------------
  // --- METHODS TO INTERACT WITH DATA SOURCE (FIRESTORE) ---
  // ---------------------------------------------------------------------------
  
  /// Creates a Model from a Firestore Document.
  /// This is used when READING data from Firestore.
  factory AppointmentModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id, // Get the ID directly from the document snapshot
      doctorId: data['doctorId'] as String? ?? '',
      patientId: data['patientId'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      doctorPhotoUrl: data['doctorPhotoUrl'] as String? ?? '',
      appointmentDateTime: data['appointmentDateTime'] as Timestamp? ?? Timestamp.now(),
      status: data['status'] as String? ?? 'pending',
      consultationFee: data['consultationFee'] as int? ?? 0,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Converts the Model to a Map for WRITING to Firestore.
  /// The document 'id' is not included in the map as it's the document's name.
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
    };
  }

  // ---------------------------------------------------------------------------
  // --- METHODS TO CONVERT BETWEEN DOMAIN AND DATA LAYERS ---
  // ---------------------------------------------------------------------------
  
  /// Converts this Data Layer Model into a Domain Layer Entity.
  /// This is used before returning data from the Repository.
  AppointmentEntity toDomain() {
    return AppointmentEntity(
      id: id,
      doctorId: doctorId,
      patientId: patientId,
      doctorName: doctorName,
      patientName: patientName,
      doctorPhotoUrl: doctorPhotoUrl,
      appointmentDateTime: appointmentDateTime.toDate(), // Convert Timestamp to DateTime
      status: status,
      consultationFee: consultationFee,
      createdAt: createdAt.toDate(), // Convert Timestamp to DateTime
    );
  }

  /// Creates a Model from a Domain Entity.
  /// This is used when the Repository receives an Entity to be saved.
  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id, // ID might be empty if it's a new appointment
      doctorId: entity.doctorId,
      patientId: entity.patientId,
      doctorName: entity.doctorName,
      patientName: entity.patientName,
      doctorPhotoUrl: entity.doctorPhotoUrl,
      appointmentDateTime: Timestamp.fromDate(entity.appointmentDateTime), // Convert DateTime to Timestamp
      status: entity.status,
      consultationFee: entity.consultationFee,
      createdAt: Timestamp.fromDate(entity.createdAt), // Convert DateTime to Timestamp
    );
  }
}