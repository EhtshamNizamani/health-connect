
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/core/shared/widgets/search_bar.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_bloc.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_state.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_event.dart';
import 'package:health_connect/features/patient/home/presentation/widgets/doctor_card.dart';

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Doctors"),
      ),
      body: BlocProvider(
        create: (context) => sl<DoctorListBloc>()..add(FetchDoctorsList()),
        // Use a Builder widget to get a context that is below the BlocProvider
        child: Builder(
          builder: (builderContext) {
            return Column(
              children: [
                // --- WIDGET 1: SEARCH BAR ---
                // Now we need to pass the BLoC to the search bar.
                // We use BlocProvider.value to provide the existing BLoC instance.
                BlocProvider.value(
                  value: BlocProvider.of<DoctorListBloc>(builderContext),
                  child: const CustomSearchBar(),
                ),

                // --- WIDGET 2: THE LIST (inside BlocBuilder) ---
                Expanded(
                  child: BlocBuilder<DoctorListBloc, DoctorListState>(
                    builder: (context, state) {
                      if (state is DoctorListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is DoctorListLoaded) {
                        final doctors = state.filteredDoctors; // Use the filtered list
                        if (doctors.isEmpty) {
                          return const Center(child: Text("No doctors found."));
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<DoctorListBloc>().add(FetchDoctorsList());
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8.0),
                            itemCount: doctors.length,
                            itemBuilder: (context, index) {
                              final doctor = doctors[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: DoctorCard(doctor: doctor),
                              );
                            },
                          ),
                        );
                      }

                      if (state is DoctorListError) {
                        return Center(child: Text(state.message));
                      }
                      
                      return const Center(child: Text("Fetching doctors..."));
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}