
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_bloc.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_bloc_state.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () { /* TODO: Implement search */ },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => sl<DoctorListBloc>()..add(FetchDoctorsList()),
        child: BlocBuilder<DoctorListBloc, DoctorListState>(
          // Give the context a name so we can use it inside
          builder: (builderContext, state) { 
            if (state is DoctorListLoading && state.doctors.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DoctorListLoaded || (state is DoctorListLoading && state.doctors.isNotEmpty)) {
              final doctors = state.doctors;
              if (doctors.isEmpty) {
                return const Center(child: Text("No doctors have registered yet."));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  // THE FIX: Use the context from the BlocBuilder ('builderContext')
                  builderContext.read<DoctorListBloc>().add(FetchDoctorsList());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8.0),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return DoctorCard(doctor: doctor);
                  },
                ),
              );
            }

            if (state is DoctorListError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Something went wrong:\n${state.message}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              );
            }
            
            return const Center(child: Text("Fetching doctors..."));
          },
        ),
      ),
    );
  }
}