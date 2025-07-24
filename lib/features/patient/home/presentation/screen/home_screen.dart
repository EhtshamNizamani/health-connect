import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_bloc.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_bloc_state.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_event.dart';
import 'package:health_connect/features/patient/home/presentation/widget/doctor_card.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The BlocProvider creates the DoctorListBloc.
      // Everything inside its 'child' can access it.
      body: BlocProvider(
        create: (context) => sl<DoctorListBloc>()..add(FetchDoctorsList()),
        
        // <<<--- THE FIX IS HERE: THE BUILDER WIDGET ---
        // The Builder widget's only job is to give you a NEW BuildContext
        // that is a DESCENDANT of the BlocProvider.
        child: Builder(
          builder: (context) { // This 'context' is now "under" the BlocProvider and can find it.
            
            final theme = Theme.of(context);

            return RefreshIndicator(
              onRefresh: () async {
                // Now, when we use 'context' here, it's the one from the Builder,
                // which can successfully find the DoctorListBloc. The error will be gone.
                context.read<DoctorListBloc>().add(FetchDoctorsList());
              },
              child: CustomScrollView(
                slivers: [
                  // SliverAppBar for a nice scrolling effect
                  SliverAppBar(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    elevation: 0,
                    pinned: true,
                    title: Text(
                      'Find Your Doctor',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    centerTitle: false,
                    actions: [
                      IconButton(
                        icon: Icon(Icons.notifications_none, color: theme.colorScheme.onBackground),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  // Header
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Text(
                        'All Doctors',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  // The main BlocBuilder for the doctor list
                  BlocBuilder<DoctorListBloc, DoctorListState>(
                    builder: (context, state) {
                      // This part of your code was already perfect. No changes needed here.
                      if (state is DoctorListLoading && state.doctors.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (state is DoctorListLoaded || (state is DoctorListLoading && state.doctors.isNotEmpty)) {
                        final doctors = state.doctors;
                        if (doctors.isEmpty) {
                          return const SliverFillRemaining(
                            child: Center(child: Text("No doctors found.")),
                          );
                        }
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final doctor = doctors[index];
                                return DoctorCard(doctor: doctor);
                              },
                              childCount: doctors.length,
                            ),
                          ),
                        );
                      }
                      if (state is DoctorListError) {
                        return SliverFillRemaining(
                          child: Center(child: Text("Error: ${state.message}")),
                        );
                      }
                      return const SliverFillRemaining(
                        child: Center(child: Text("Search for doctors to get started.")),
                      );
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