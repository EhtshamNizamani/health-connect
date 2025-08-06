import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/patient/doctor_list/domain/entities/paginated_doctors_result.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';

abstract class DoctorRepository {
  /// Fetches a paginated list of doctors from the data source.
  Future<Either<Failure, PaginatedDoctorsResult>> getDoctors({
    // <<<--- THE FIX ---
    // Use named, optional parameters with types for clarity and safety.
    required int limit,
    DocumentSnapshot? lastDocument,
    // <<<--------------->>>
  });
}