import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/constants/app_color.dart';
import 'package:health_connect/core/shared/widgets/custom_button.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/presentation/blocs/booking_bloc.dart';
import 'package:health_connect/features/appointment/presentation/blocs/booking_event.dart';
import 'package:health_connect/features/appointment/presentation/blocs/booking_state.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_bloc.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_state.dart';

class AppointmentBookingBottomBar extends StatelessWidget {
  const AppointmentBookingBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the main screen's BLoC
    return BlocBuilder<DoctorProfileViewBloc, DoctorProfileViewState>(
      builder: (context, state) {
        // Ensure we are in the loaded state
        if (state is! DoctorProfileViewLoaded) {
          return const SizedBox.shrink();
        }

        // Get all necessary data from the single state
        final doctor = state.doctor;
        final selectedSlot = state.selectedSlot;
        final patient = context.read<AuthBloc>().state as AuthenticatedPatient;
        final patientId = patient.user.id;
        final patientName = patient.user.name;

        return BlocListener<BookingBloc, BookingState>(
          listener: (context, bookingState){
            if(bookingState is BookingSuccess){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: AppColors.primary, content: Text("Appointment booked successfully!")));
            }
             if (bookingState is BookingFailure) {
              // If the state is BookingFailure, show a SnackBar with the error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(bookingState.message), // The message comes directly from the state
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
            // <<< ----------------------------------------------
          },
          child: BlocBuilder<BookingBloc, BookingState>(
            builder: (context, bookingState) {

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomButton(
                  isLoading: bookingState is BookingInProgress,
                  onTap: selectedSlot == null
                      ? null
                      : () {
                          final newAppointment = AppointmentEntity(
                            id: '',
                            doctorId: doctor.uid,
                            patientId: patientId,
                            doctorName: doctor.name,
                            patientName: patientName,
                            doctorPhotoUrl: doctor.photoUrl,
                            appointmentDateTime: selectedSlot,
                            status: 'pending',
                            consultationFee: doctor.consultationFee,
                            createdAt: DateTime.now(),
                          );
                          context.read<BookingBloc>().add(
                            AppointmentBookingRequested(newAppointment),
                          );
                        },
                  text: "Book Appointment",
                ),
              ),
            );
          },
        ));
      },
    );
  }
}
