import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_bloc.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_bloc_state.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_event.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/screens/doctor_profile_view_screen.dart';
import 'package:health_connect/features/patient/home/presentation/widgets/doctor_card.dart';
part '../widgets/_section_header.dart';
part '../widgets/_welcome_section.dart';
part '../widgets/_specialties_section.dart';
part '../widgets/_top_doctors_section.dart';
part '../widgets/_search_bar.dart';


class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final userName = (context.watch<AuthBloc>().state as AuthenticatedPatient).user.name;

  return Scaffold(
    backgroundColor: theme.scaffoldBackgroundColor,
    body: BlocProvider(
      create: (context) => sl<DoctorListBloc>()..add(FetchDoctorsList()),
      
      // <<< --- THE FIX: WRAP THE REFRESHINDICATOR IN A BUILDER ---
      child: Builder(
        builder: (context) { // This 'context' is now a descendant of BlocProvider and can find it.
          
          return RefreshIndicator(
            onRefresh: () async {
              // Now this 'context' is the correct one, and the error is gone.
              context.read<DoctorListBloc>().add(FetchDoctorsList());
            },
            child: CustomScrollView(
              slivers: [
                // Section 1: Welcome Header
                _WelcomeSection(userName: userName),

                // Section 2: Search Bar
                const _SearchBar(),

                // Section 3: Specialties
                const _SectionHeader(title: "Specialties"),
                const _SpecialtiesSection(),

                // Section 4: Top Rated Doctors
                const _SectionHeader(title: "Top Rated Doctors"),
                const _TopDoctorsSection(),

                // Section 5: All Doctors
                const _SectionHeader(title: "All Doctors"),
                BlocBuilder<DoctorListBloc, DoctorListState>(
                  builder: (context, state) {
                    // ... (Your existing BlocBuilder logic, no changes needed here)
                    if (state is DoctorListLoading && state.doctors.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(heightFactor: 5, child: CircularProgressIndicator()),
                      );
                    }
                    if (state.doctors.isNotEmpty) {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => DoctorCard(doctor: state.doctors[index]),
                            childCount: state.doctors.length,
                          ),
                        ),
                      );
                    }
                    if (state is DoctorListError) {
                      return SliverToBoxAdapter(child: Center(child: Text(state.message)));
                    }
                    return const SliverToBoxAdapter(child: Center(child: Text("No doctors found.")));
                  },
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
}
