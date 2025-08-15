import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/doctor/review/domain/usecase/get_doctor_review_usecase.dart';
import 'package:health_connect/features/doctor/review/domain/usecase/submit_review_usecase.dart';
import 'package:health_connect/features/doctor/review/presantation/bloc/review_event.dart';
import 'package:health_connect/features/doctor/review/presantation/bloc/review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final GetDoctorReviewUseCase _getDoctorReviewUseCase;
  final SubmitReviewUseCase _submitReviewUseCase;

  ReviewBloc(this._getDoctorReviewUseCase, this._submitReviewUseCase)
    : super(InitialReviewState()) {
    on<FetchReviews>(_fetchReviews);
    on<SubmitReview>(_submitReview);
  }
  Future<void> _fetchReviews(
    FetchReviews event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      emit(ReviewLoadingState());
      final result = await _getDoctorReviewUseCase(event.doctorId);
      result.fold(
        (failure) => emit(ReviewFailureState(failure.message)),
        (reviews) => emit(ReviewLoadedState(reviews)),
      );
    } catch (e) {
      emit(ReviewFailureState(e.toString()));
    }
  }

  Future<void> _submitReview(
    SubmitReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoadingState());
    try {
      final result = await _submitReviewUseCase(
        event.doctorId,
        event.appointmentId,
        event.review,
      );
      result.fold(
        (l) => emit(ReviewFailureState(l.message)),
        (_) => emit(ReviewSuccessState()),
      );
    } catch (e) {
      emit(ReviewFailureState(e.toString()));
    }
  }
}
