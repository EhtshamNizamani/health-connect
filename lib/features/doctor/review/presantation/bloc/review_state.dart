import 'package:equatable/equatable.dart';
import 'package:health_connect/features/doctor/review/domain/entity/review_entity.dart';

abstract class ReviewState extends Equatable{
 const ReviewState();
@override
  List<Object> get props =>[];
}

class InitialReviewState extends ReviewState{}
class ReviewLoadingState extends ReviewState{}
class ReviewSuccessState extends ReviewState{}
class ReviewFailureState extends ReviewState{
  final String message;
  const ReviewFailureState(this.message)
  ;
  @override
  List<Object> get props => [message];
}
class ReviewLoadedState extends ReviewState{
  final List<ReviewEntity> reviews;
   const ReviewLoadedState(this.reviews);
  @override
  List<Object> get props => [reviews];
}