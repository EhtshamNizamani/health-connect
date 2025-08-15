import 'package:equatable/equatable.dart';

abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object> get props => [];
}

class BookingInitial extends BookingState {}

// When the booking process is in progress
class BookingInProgress extends BookingState {}

// When the booking is successful
class BookingSuccess extends BookingState {}

// When the booking is loading
class BookingLoading extends BookingState {}

// When the booking fails
class BookingFailure extends BookingState {
  final String message;
  const BookingFailure(this.message);
  
  @override
  List<Object> get props => [message];
}