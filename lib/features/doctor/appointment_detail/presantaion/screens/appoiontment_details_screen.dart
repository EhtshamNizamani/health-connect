import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/bloc/appointment_details_bloc.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/bloc/appointment_details_event.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/bloc/appointment_details_state.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/widgets/patient_snapshot_card.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/widgets/quick_action_button.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/widgets/recent_visit_list.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/widgets/section_title.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/widgets/sticky_patient_header.dart';
import 'package:shimmer/shimmer.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String appointmentId; // Humein appointmentId chahiye hoga is screen ko kholne ke liye

  const AppointmentDetailScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  Widget  build(BuildContext context) {
    return BlocProvider(
      // BLoC ko create karein aur foran data fetch karne ke liye event bhejein
      create: (context) => sl<AppointmentDetailBloc>()
        ..add(FetchAppointmentDetails(appointmentId)),
      child: Scaffold(
        // Use BlocBuilder to change the entire body based on the state
        body: BlocBuilder<AppointmentDetailBloc, AppointmentDetailState>(
          builder: (context, state) {
            // State 1: Loading -> Show a full-screen skeleton UI
            if (state is AppointmentDetailLoading || state is AppointmentDetailInitial) {
              return const _AppointmentDetailSkeleton();
            }

            // State 2: Error -> Show an error message
            if (state is AppointmentDetailError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(state.message, textAlign: TextAlign.center),
                ),
              );
            }

            // State 3: Loaded -> Show the real data
            if (state is AppointmentDetailLoaded) {
              final details = state.details;
              final appointment = details.appointment;
              final patient = details.patient;

              return CustomScrollView(
                slivers: [
                  // Pass real data to the sticky header
                  StickyPatientHeader(
                    patientName: patient.name,
                    // Assume age/gender is available, otherwise show empty string
                    patientAgeGender: "32M", // Replace with real data if you have it
                    appointmentTime: appointment.appointmentDateTime,
                    appointmentStatus: appointment.status,
                    patientImageUrl: patient.photoUrl ?? '',
                  ),

                  // Main Content Area
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(title: "Quick Actions"),
                          const SizedBox(height: 16),
                          // Pass real status to the buttons
                          QuickActionButtons(status: appointment.status,appointment:appointment),
                          const SizedBox(height: 32),

                          const SectionTitle(title: "Patient Snapshot"),
                          const SizedBox(height: 16),
                          // Pass real patient data to the snapshot card
                          PatientSnapshotCard(patient: patient),
                          const SizedBox(height: 32),

                          SectionTitle(title: "Recent Visits", onViewAll: () {}),
                          const SizedBox(height: 16),
                          // Pass real visit history to the list
                          RecentVisitsList(visits: details.recentVisits),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            
            // Fallback for any other unhandled state
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}


// --- A SKELETON WIDGET FOR THE LOADING STATE ---
class _AppointmentDetailSkeleton extends StatelessWidget {
  const _AppointmentDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          // Skeleton for the header
          const SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            backgroundColor: Colors.white,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skeleton for Quick Actions
                  _buildSkeletonBlock(height: 20, width: 150),
                  const SizedBox(height: 16),
                  _buildSkeletonBlock(height: 50),
                  const SizedBox(height: 32),

                  // Skeleton for Patient Snapshot
                  _buildSkeletonBlock(height: 20, width: 180),
                  const SizedBox(height: 16),
                  _buildSkeletonBlock(height: 150),
                   const SizedBox(height: 32),

                  // Skeleton for Recent Visits
                  _buildSkeletonBlock(height: 20, width: 120),
                  const SizedBox(height: 16),
                  _buildSkeletonBlock(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonBlock({double height = 20, double? width}) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}