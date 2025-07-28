import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id; // The document ID of the review itself
  final double rating;
  final String comment;
  final String patientId;
  final String patientName;
  final String? patientPhotoUrl; // Optional
  final Timestamp timestamp;

  const ReviewEntity({
    required this.id,
    required this.rating,
    required this.comment,
    required this.patientId,
    required this.patientName,
    this.patientPhotoUrl,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id, rating, comment, patientId, patientName, patientPhotoUrl, timestamp
  ];
}