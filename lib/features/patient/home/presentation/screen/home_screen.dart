import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_bloc.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_state.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_event.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/screen/doctor_list.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/screens/doctor_profile_view_screen.dart';
import 'package:health_connect/features/patient/home/presentation/widgets/doctor_card.dart';
part '../widgets/_section_header.dart';
part '../widgets/_welcome_section.dart';
part '../widgets/_specialties_section.dart';
part '../widgets/_top_doctors_section.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = authState.user?.name ?? "Guest";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Provide the DoctorListBloc here so all child sections can access it
      body: BlocProvider(
        create: (context) => sl<DoctorListBloc>()..add(FetchInitialDoctors()),
        child: Builder(
          builder: (context) {
            return RefreshIndicator(
              onRefresh: () async {
                // When user pulls to refresh, fetch the first page again
                context.read<DoctorListBloc>().add(FetchInitialDoctors());
              },
              child: CustomScrollView(
                slivers: [
                  _WelcomeSection(userName: userName),
                  // We will create this search bar later
                  // const _SearchBar(), 
                  const _SectionHeader(title: "Specialties"),
                  const _SpecialtiesSection(),
                  const _SectionHeader(title: "Top Rated Doctors"),
                  const _TopDoctorsSection(), // This widget is now fixed
                  _SectionHeader(
                    title: "All Doctors",
                    actionWidget: TextButton(
                      onPressed: () {
                        // Navigate to the full, paginated list screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DoctorListScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "View All",
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                  
                  // --- THE FIX FOR THE "ALL DOCTORS" LIST ---
                  BlocBuilder<DoctorListBloc, DoctorListState>(
                    builder: (context, state) {
                      // Show a loader only on the very first fetch
                      if (state.isLoadingFirstPage) {
                        return const SliverToBoxAdapter(
                          child: Center(heightFactor: 5, child: CircularProgressIndicator()),
                        );
                      }
                      
                      if (state.doctors.isEmpty && !state.isLoadingFirstPage) {
                        return const SliverToBoxAdapter(
                          child: Center(heightFactor: 5, child: Text("No doctors available.")),
                        );
                      }

                      if (state.errorMessage != null) {
                        return SliverToBoxAdapter(child: Center(child: Text(state.errorMessage!)));
                      }

                      // We only want to show a few doctors on the home screen
                      final doctorsToShow = state.doctors.take(4).toList();

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => DoctorCard(doctor: doctorsToShow[index]),
                            childCount: doctorsToShow.length,
                          ),
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}