import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/features/doctor/review/domain/entity/review_entity.dart';

class ReviewModel {
  final String id;
  final double rating;
  final String comment;
  final String patientId;
  final String patientName;
  final String? patientPhotoUrl;
  final Timestamp timestamp;

  const ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.patientId,
    required this.patientName,
    this.patientPhotoUrl,
    required this.timestamp,
  });

  // Method to convert a Firestore DocumentSnapshot into a ReviewModel
  factory ReviewModel.fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return ReviewModel(
      id: snap.id, // Get the document ID from the snapshot itself
      rating: (snapshot['rating'] as num?)?.toDouble() ?? 0.0,
      comment: snapshot['comment'] as String? ?? '',
      patientId: snapshot['patientId'] as String? ?? '',
      patientName: snapshot['patientName'] as String? ?? '',
      patientPhotoUrl: snapshot['patientPhotoUrl'] as String?,
      timestamp: snapshot['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }

  // Method to convert a ReviewModel instance into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'comment': comment,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhotoUrl': patientPhotoUrl,
      'timestamp': timestamp,
    };
  }

  // Method to convert the Data Model to a Domain Entity
  ReviewEntity toDomain() {
    return ReviewEntity(
      id: id,
      rating: rating,
      comment: comment,
      patientId: patientId,
      patientName: patientName,
      patientPhotoUrl: patientPhotoUrl,
      timestamp: timestamp,
    );
  }

  // Factory method to create a Data Model from a Domain Entity
  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      rating: entity.rating,
      comment: entity.comment,
      patientId: entity.patientId,
      patientName: entity.patientName,
      patientPhotoUrl: entity.patientPhotoUrl,
      timestamp: entity.timestamp,
    );
  }
}