import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/review/domain/entity/review_entity.dart';
import 'package:health_connect/features/doctor/review/domain/repository/review_repository.dart';

class GetDoctorReviewUseCase {
    final ReviewRepository repository;
    GetDoctorReviewUseCase(this.repository);

    Future<Either<Failure, List<ReviewEntity>>> call(String doctorId) {
        return repository.getDoctorReviews(doctorId);
    }
}