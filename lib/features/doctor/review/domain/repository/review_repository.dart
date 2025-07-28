import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/review/domain/entity/review_entity.dart';

abstract class ReviewRepository {

  Future<Either<Failure,void>> submitReview(String doctorId,String appointmentId, ReviewEntity review);
  Future<Either<Failure,List<ReviewEntity>>> getDoctorReviews(String doctorId);
}