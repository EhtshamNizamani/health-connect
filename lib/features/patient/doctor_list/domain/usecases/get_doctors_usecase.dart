import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/patient/doctor_list/domain/entities/paginated_doctors_result.dart';
import 'package:health_connect/features/patient/doctor_list/domain/repositories/doctor_repository.dart';

// The UseCase now implements our standard contract
class GetDoctorsUseCase implements UseCase<PaginatedDoctorsResult, GetDoctorsParams> {
  final DoctorRepository repository;

  GetDoctorsUseCase(this.repository);

  // The call method now takes the single Params object
  @override
  Future<Either<Failure, PaginatedDoctorsResult>> call(GetDoctorsParams params) async {
    return await repository.getDoctors(
      limit: params.limit,
      lastDocument: params.lastDocument,
    );
  }
}

// A dedicated class for the parameters
class GetDoctorsParams extends Equatable {
  final int limit;
  final DocumentSnapshot? lastDocument;

  const GetDoctorsParams({
    this.limit = 15,
    this.lastDocument,
  });
  
  @override
  List<Object?> get props => [limit, lastDocument];
}