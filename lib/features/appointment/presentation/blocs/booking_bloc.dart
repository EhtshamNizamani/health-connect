import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/appointment/domain/usecases/book_appointment_usecase.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookAppointmentUseCase _bookAppointmentUseCase;

  BookingBloc(this._bookAppointmentUseCase) : super(BookingInitial()) {
    on<AppointmentBookingRequested>(_onAppointmentBookingRequested);
  }

  Future<void> _onAppointmentBookingRequested(
    AppointmentBookingRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingInProgress());
    
    final result = await _bookAppointmentUseCase(event.appointment);
    
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (_) => emit(BookingSuccess()),
    );
  }
}