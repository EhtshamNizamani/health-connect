import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id; // This will be the Firestore document ID
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final String doctorPhotoUrl;
  final DateTime appointmentDateTime;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final int consultationFee;
  final DateTime createdAt;
  final bool isReviewed;
  final bool isReadByDoctor;
  final bool isReadByPatient;
  
  const AppointmentEntity({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.doctorName,
    required this.patientName,
    required this.doctorPhotoUrl,
    required this.appointmentDateTime,
    required this.status,
    required this.consultationFee,
    required this.isReadByDoctor,
    required this.createdAt,
    required this.isReadByPatient,
    this.isReviewed = false,
  });

  @override
  List<Object?> get props => [id, doctorId, patientId, appointmentDateTime];
}