import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/data/models/doctor_model.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/patient/doctor_list/domain/entities/paginated_doctors_result.dart';
import 'package:health_connect/features/patient/doctor_list/domain/repositories/doctor_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';

class FirebaseDoctorRepositoryImpl implements DoctorRepository {
  final FirebaseFirestore _firestore;
  FirebaseDoctorRepositoryImpl(this._firestore);

  @override
  // <<<--- THE FIX ---
  // The method signature now exactly matches the abstract class.
  Future<Either<Failure, PaginatedDoctorsResult>> getDoctors({
    required int limit,
    DocumentSnapshot? lastDocument,
  }) async {
  // <<<--------------->>>
    try {
      Query query = _firestore
          .collection('doctors')
          .orderBy('name')
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

      final List<DoctorEntity> doctors = querySnapshot.docs
          .map(
            (doc) => DoctorModel.fromSnapshot(doc).toDomain(), // Use fromSnapshot if available
          )
          .toList();
      
      // The rest of your logic is already perfect.
      final newLastDocument = querySnapshot.docs.isNotEmpty
          ? querySnapshot.docs.last
          : null;
      final hasMore = doctors.length == limit;

      return Right(
        PaginatedDoctorsResult(
          doctors: doctors,
          lastDocument: newLastDocument,
          hasMore: hasMore,
        ),
      );
    } catch (e) {
      return Left(ServerFailure( "Failed to fetch doctors: $e"));
    }
  }
}