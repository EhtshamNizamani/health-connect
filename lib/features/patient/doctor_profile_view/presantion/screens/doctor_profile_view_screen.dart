import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/patient/appointment/presentation/bloc/patient_appointments_bloc.dart';
import 'package:health_connect/features/patient/appointment/presentation/bloc/patient_appointments_event.dart';
import 'package:health_connect/features/doctor/review/presantation/bloc/review_bloc.dart';
import 'package:health_connect/features/doctor/review/presantation/bloc/review_event.dart';
import 'package:health_connect/features/doctor/review/presantation/bloc/review_state.dart';
import 'package:health_connect/features/patient/appointment/presentation/bloc/patient_appointments_state.dart';
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
      print("✅ Patient ID found: $patientId");
    } else {
      print("❌ Warning: User is not in AuthenticatedPatient state.");
    }
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<DoctorProfileViewBloc>()..add(FetchDoctorDetailsViewEvent(doctorId)),
        ),
        BlocProvider(
          create: (context) => sl<ReviewBloc>()..add(FetchReviews(doctorId)),
        ),
        // ❗ IMPORTANT: Create a fresh PatientAppointmentsBloc instance instead of using global one
        BlocProvider(
          create: (context) {
            print("🚀 Creating PatientAppointmentsBloc for chat access");
            final bloc = sl<PatientAppointmentsBloc>();
            if (patientId.isNotEmpty) {
              print("📋 Triggering FetchPatientAppointments for patient: $patientId");
              bloc.add(FetchPatientAppointments());
            }
            return bloc;
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: BackButton(color: Theme.of(context).colorScheme.onSurface),
        ),
        body: BlocBuilder<DoctorProfileViewBloc, DoctorProfileViewState>(
          builder: (context, doctorState) {
            if (doctorState is DoctorProfileViewLoading || doctorState is DoctorProfileViewInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (doctorState is DoctorProfileViewError) {
              return Center(child: Text(doctorState.message));
            }
            if (doctorState is DoctorProfileViewLoaded) {
              final doctor = doctorState.doctor;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 100.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor's Basic Info with Chat Access Logic
                      DoctorProfileHeader(doctor: doctor, patientId: patientId),
                      const SizedBox(height: 24),
                      AboutSection(bio: doctor.bio),
                      const SizedBox(height: 24),

                      // Doctor's Detailed Info Cards
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

                      // Date and Time Slot Selector
                      DateAndTimeSelector(doctorId: doctor.uid),
                      const SizedBox(height: 32),

                      // Reviews Section
                      Text(
                        "Ratings & Reviews",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
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
                            return ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: reviewState.reviews.length,
                              separatorBuilder: (context, index) => const Divider(height: 24),
                              itemBuilder: (context, index) {
                                final review = reviewState.reviews[index];
                                return ReviewCard(review: review); 
                              },
                            );
                          }
                          if (reviewState is ReviewFailureState) {
                            return Center(child: Text(reviewState.message));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      
                      ]  
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: BlocBuilder<DoctorProfileViewBloc, DoctorProfileViewState>(
          builder: (context, state) {
            if (state is DoctorProfileViewLoaded) {
              return AppointmentBookingBottomBar();
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}