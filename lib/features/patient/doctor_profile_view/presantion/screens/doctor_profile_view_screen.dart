import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart'; // get_it ke liye
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
  DoctorProfileScreen({super.key, required this.doctorId});

  // Dummy data for now
  final List<Map<String, dynamic>> dummyReviews = [
    {
      'name': 'Ali Raza',
      'review':
          'Excellent care and very professional. Dr. Sharma explained everything clearly. Highly recommended!',
      'rating': 5.0,
      'date': 'July 15, 2024',
    },
    {
      'name': 'Sana Mirza',
      'review':
          'Very kind and attentive doctor. The clinic was clean and the staff was helpful. Good experience overall.',
      'rating': 4.0,
      'date': 'June 28, 2024',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<DoctorProfileViewBloc>()..add(FetchDoctorDetailsViewEvent(doctorId)),
      child: Scaffold(
        // AppBar ko aasan rakhein ya use header mein hi merge kar dein
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        body: BlocBuilder<DoctorProfileViewBloc, DoctorProfileViewState>(
          builder: (context, state) {
            if (state is DoctorProfileViewLoading ||
                state is DoctorProfileViewInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DoctorProfileViewLoaded) {
              final doctor = state.doctor;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DoctorProfileHeader(doctor: doctor),
                    const SizedBox(height: 24),
                    AboutSection(bio: doctor.bio),
                    const SizedBox(height: 24),
                    InfoCard(
                      icon: Icons.location_on,
                      title: "Clinic Address",
                      subtitle: doctor.clinicAddress,
                    ),
                    const SizedBox(height: 16),
                    // Static for now
                    const InfoCard(
                      icon: Icons.calendar_today,
                      title: "Availability",
                      subtitle: "Mon - Sat | 10:00 AM - 04:00 PM",
                    ),
                    const SizedBox(height: 16),
                    InfoCard(
                      icon: Icons.money,
                      title: "Consultation Fee",
                      subtitle: "₹${doctor.consultationFee} / visit",
                    ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DateAndTimeSelector(doctorId: doctor.uid),
                    ),
                    const SizedBox(height: 24),
                    // List of ReviewCards
                    ...dummyReviews.map((reviewData) {
                      return ReviewCard(
                        patientName: reviewData['name'],
                        reviewText: reviewData['review'],
                        rating: reviewData['rating'],
                        date: reviewData['date'],
                      );
                    }),
                    // Add space at the bottom so content isn't hidden by the button
                    const SizedBox(height: 80),
                  ],
                ),
              );
            }
            if (state is DoctorProfileViewError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
        // Use bottomNavigationBar for the fixed button
        bottomNavigationBar:
            BlocBuilder<DoctorProfileViewBloc, DoctorProfileViewState>(
              builder: (context, state) {
                if (state is DoctorProfileViewLoaded) {
                  return AppointmentBookingBottomBar(
                  
                  );
                }
                return const SizedBox.shrink(); // Hide button if not loaded
              },
            ),
      ),
    );
  }
}
