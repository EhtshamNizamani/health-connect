import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/review/domain/entity/review_entity.dart';
import 'package:health_connect/features/doctor/review/domain/repository/review_repository.dart';

class SubmitReviewUseCase {
  final ReviewRepository repository;
  SubmitReviewUseCase(this.repository);
  Future<Either<Failure, void>> call(
    String doctorId,
    String appointmentId,
    ReviewEntity review,
  ) {
    return repository.submitReview(doctorId, appointmentId, review);
  }
}
