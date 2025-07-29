import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart'; // get_it ke liye
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/doctor/review/presantation/bloc/review_bloc.dart';
import 'package:health_connect/features/doctor/review/presantation/bloc/review_event.dart';
import 'package:health_connect/features/doctor/review/presantation/bloc/review_state.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_bloc.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_event.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_state.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/widget/about_section.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/widget/appointment_booking_bottom_bar.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/widget/date_and_time_selector.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/widget/doctor_profile_header.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/widget/info_card.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/widget/review_card.dart';

class DoctorProfileScreen extends StatelessWidget {
  final String doctorId;
  const DoctorProfileScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
   final authState = context.read<AuthBloc>().state;
    String patientId = '';
    if (authState is AuthenticatedPatient) {
      patientId = authState.user.id;
    } else {
      // Handle the case where the user might not be a patient, although unlikely here.
      // This could be a guest or another role. You might want to disable chat in that case.
      print("Warning: User is not in AuthenticatedPatient state.");
    }
    // Use MultiBlocProvider to provide both BLoCs at the top of the screen's widget tree.
    // Both BLoCs will be created and will start fetching data as soon as this screen is built.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<DoctorProfileViewBloc>()..add(FetchDoctorDetailsViewEvent(doctorId)),
        ),
        BlocProvider(
          create: (context) => sl<ReviewBloc>()..add(FetchReviews(doctorId)),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          // Use the theme's icon color for the back button
          leading: BackButton(color: Theme.of(context).colorScheme.onSurface),
        ),
        // The main content of the screen is built by the DoctorProfileViewBloc
        body: BlocBuilder<DoctorProfileViewBloc, DoctorProfileViewState>(
          builder: (context, doctorState) {
            // --- Loading State ---
            if (doctorState is DoctorProfileViewLoading || doctorState is DoctorProfileViewInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            // --- Error State ---
            if (doctorState is DoctorProfileViewError) {
              return Center(child: Text(doctorState.message));
            }
            // --- Loaded State ---
            if (doctorState is DoctorProfileViewLoaded) {
              final doctor = doctorState.doctor;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 100.0), // Add padding at the bottom
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Doctor's Basic Info ---
                      DoctorProfileHeader(doctor: doctor, patientId: patientId),
                      const SizedBox(height: 24),
                      AboutSection(bio: doctor.bio),
                      const SizedBox(height: 24),

                      // --- Doctor's Detailed Info Cards ---
                      InfoCard(
                        icon: Icons.location_on_outlined,
                        title: "Clinic Address",
                        subtitle: doctor.clinicAddress,
                      ),
                      const SizedBox(height: 16),
                      InfoCard(
                        icon: Icons.money_outlined,
                        title: "Consultation Fee",
                        subtitle: "₹${doctor.consultationFee} / visit",
                      ),
                      const SizedBox(height: 24),

                      // --- Date and Time Slot Selector ---
                      DateAndTimeSelector(doctorId: doctor.uid),
                      const SizedBox(height: 32),

                      // --- Reviews Section ---
                       Text(
                        "Ratings & Reviews",
                       style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ), ),
                      const SizedBox(height: 8),
                      
                      // This BlocBuilder handles only the review part of the UI
                      BlocBuilder<ReviewBloc, ReviewState>(
                        builder: (context, reviewState) {
                          if (reviewState is ReviewLoadingState) {
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          }
                          if (reviewState is ReviewLoadedState) {
                            if (reviewState.reviews.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.0),
                                  child: Text("No reviews yet. Be the first to review!"),
                                ),
                              );
                            }
                            // Use ListView.separated to automatically add dividers between reviews
                            return ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: reviewState.reviews.length,
                              separatorBuilder: (context, index) => const Divider(height: 24),
                              itemBuilder: (context, index) {
                                final review = reviewState.reviews[index];
                                // You need to create this ReviewCard widget
                                return ReviewCard(review: review); 
                              },
                            );
                          }
                          if (reviewState is ReviewFailureState) {
                            return Center(child: Text(reviewState.message));
                          }
                          // Return an empty box for the initial state
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            // Fallback for any other state
            return const SizedBox.shrink();
          },
        ),
        // The bottom navigation bar is also controlled by the DoctorProfileViewBloc
        // It only shows up when the main profile data is loaded.
        bottomNavigationBar: BlocBuilder<DoctorProfileViewBloc, DoctorProfileViewState>(
          builder: (context, state) {
            if (state is DoctorProfileViewLoaded) {
              return AppointmentBookingBottomBar();
            }
            return const SizedBox.shrink(); // Hide the bar while loading/error
          },
        ),
      ),
    );
  }
}
