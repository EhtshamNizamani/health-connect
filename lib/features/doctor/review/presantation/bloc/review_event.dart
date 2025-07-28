import 'package:equatable/equatable.dart';
import 'package:health_connect/features/doctor/review/domain/entity/review_entity.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object> get props => [];
}

class FetchReviews extends ReviewEvent{
  final String doctorId;
  const FetchReviews( this.doctorId);
  @override
  List<Object> get props => [doctorId];
}
class SubmitReview extends ReviewEvent{
  final String doctorId;
  final String appointmentId;
  final ReviewEntity review;
  const SubmitReview( this.doctorId,this.appointmentId, this.review);
  @override
  List<Object> get props => [doctorId,appointmentId,review];
}