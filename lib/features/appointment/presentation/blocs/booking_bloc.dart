import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:health_connect/core/services/stripe_payment_service.dart';
import 'package:health_connect/features/appointment/domain/usecases/book_appointment_usecase.dart';
import 'package:health_connect/features/appointment/domain/usecases/initiate_payment.dart';
import 'package:health_connect/features/appointment/presentation/blocs/booking_event.dart';
import 'package:health_connect/features/appointment/presentation/blocs/booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookAppointmentUseCase _bookAppointmentUseCase;
  final InitiatePaymentUseCase _initiatePaymentUseCase;
  final StripePaymentService _stripeService;

  BookingBloc(
    this._bookAppointmentUseCase,
    this._initiatePaymentUseCase,
    this._stripeService,
  ) : super(BookingInitial()) {
    on<PaymentAndBookingStarted>(_onPaymentAndBookingStarted);
  }

  Future<void> _onPaymentAndBookingStarted(
    PaymentAndBookingStarted event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      // STEP 1: Create PaymentIntent
      final paymentResult = await _initiatePaymentUseCase(
        InitiatePaymentParams(
          doctorId: event.appointmentDetails.doctorId,
          amount: event.appointmentDetails.consultationFee,
        ),
      );

      // CRITICAL FIX: paymentResult.fold ko if-else structure mein badla gaya hai
      // taake asynchronous operations theek se await ki ja saken.
      if (paymentResult.isLeft()) {
        final failure = paymentResult.fold((f) => f, (r) => throw Exception("Unreachable")); // Failure extract karein
        emit(BookingFailure("Payment Failed: ${failure.message}"));
        return; // Agar payment initiation fail ho jaye to yahan se return karein
      }

      final clientSecret = paymentResult.fold((l) => throw Exception("Unreachable"), (r) => r); // clientSecret extract karein

      try {
        // STEP 2: Init PaymentSheet
        await _stripeService.initializePaymentSheet(
          clientSecret: clientSecret,
          merchantName: 'Health Connect',
        );

        // STEP 3: Show PaymentSheet
        await _stripeService.presentPaymentSheet();

        // STEP 4: Book Appointment
        final bookingResult = await _bookAppointmentUseCase(event.appointmentDetails);
        bookingResult.fold(
          (failure) => emit(BookingFailure("Booking Failed: ${failure.message}")),
          (_) => emit(BookingSuccess()),
        );
      } on StripeException catch (e) {
        final message = e.error.localizedMessage ?? "Payment cancelled or failed.";
        emit(BookingFailure(message));
      } catch (e) {
        emit(BookingFailure("Unexpected error: $e"));
      }
    } catch (e) {
      emit(BookingFailure("Unexpected error: $e"));
    }
  }
}
