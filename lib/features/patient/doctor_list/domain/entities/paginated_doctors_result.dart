// domain/entities/paginated_doctors_result.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';

class PaginatedDoctorsResult {
  final List<DoctorEntity> doctors;
  final DocumentSnapshot? lastDocument;
  final bool hasMore; // Optional: To know if there are more documents to load

  PaginatedDoctorsResult({
    required this.doctors,
    this.lastDocument,
    this.hasMore = false,
  });
}