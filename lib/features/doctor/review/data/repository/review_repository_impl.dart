import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/doctor/review/data/model/review_model.dart';
import 'package:health_connect/features/doctor/review/domain/entity/review_entity.dart';
import 'package:health_connect/features/doctor/review/domain/repository/review_repository.dart';

class ReviewRepositoryImpl extends ReviewRepository {
  final FirebaseFirestore _firestore;
  ReviewRepositoryImpl(this._firestore);
  @override
  Future<Either<Failure, void>> submitReview(
    String doctorId,
    String appointmentId,
    ReviewEntity review,
  ) async {
    try {
      final reviewModel = ReviewModel.fromEntity(review);

      await _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('reviews')
          .add(reviewModel.toMap());
      await _firestore.collection('appointments').doc(appointmentId).update({
        'isReviewed': true,
      });
      return Right(null);
    } catch (e) {
      return Left(FirestoreFailure("Failed to submit review: $e"));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getDoctorReviews(
    String doctorId,
  ) async {
    if (doctorId.isEmpty) {
      return Left(ValidationError("Doctor ID cannot be empty"));
    }
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection("doctors")
          .doc(doctorId)
          .collection("reviews")
          .get();
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromSnapshot(doc).toDomain())
          .toList();
      return Right(reviews);
    } catch (e) {
      return Left(FirestoreFailure("Failed to fetch reviews: $e"));
    }
  }
}
