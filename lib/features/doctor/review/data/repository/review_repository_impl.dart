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
    // 1. Doctor, Appointment, aur naye Review ke document references banayein
    final doctorRef = _firestore.collection('doctors').doc(doctorId);
    final appointmentRef = _firestore.collection('appointments').doc(appointmentId);
    // Naye review ke liye ek reference banayein taaki use transaction mein use kar sakein
    final newReviewRef = doctorRef.collection('reviews').doc(); 

    try {
      // 2. Firestore Transaction chalayein
      // Transaction ke andar ka saara code server par ek saath chalta hai
      await _firestore.runTransaction((transaction) async {
        // --- Transaction ke Andar ke Steps ---

        // a. Pehle doctor ka document transaction ke andar "get" karein
        //    Isse humein current totalRating aur reviewCount mil jayega
        final doctorSnapshot = await transaction.get(doctorRef);

        if (!doctorSnapshot.exists) {
          throw Exception("Doctor document does not exist!");
        }

        // b. Purani values nikal lein (agar nahi hain to default 0)
        final currentTotalRating = (doctorSnapshot.data()!['totalRating'] as num?)?.toDouble() ?? 0.0;
        final currentReviewCount = doctorSnapshot.data()!['reviewCount'] as int? ?? 0;

        // c. Nayi values calculate karein
        //    Yehi hai aapke sawaal ka jawaab: Hum purani value mein nayi value add kar rahe hain
        final newTotalRating = currentTotalRating + review.rating; // e.g., 485.5 + 4.5 = 490.0
        final newReviewCount = currentReviewCount + 1;             // e.g., 100 + 1 = 101

        // d. Transaction ko batayein ki use kya-kya likhna (write) hai
        
        // Write #1: Naya review document create karo
        final reviewModel = ReviewModel.fromEntity(review);
        transaction.set(newReviewRef, reviewModel.toMap());

        // Write #2: Appointment ko 'isReviewed: true' set karo
        transaction.update(appointmentRef, {'isReviewed': true});

        // Write #3: Doctor ke document ko nayi rating summary ke saath update karo
        transaction.update(doctorRef, {
          'totalRating': newTotalRating,
          'reviewCount': newReviewCount,
        });
      });

      // 3. Agar transaction poora ho gaya, to success return karein
      return const Right(null);

    } catch (e) {
      // 4. Agar transaction fail hua, to failure return karein
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
