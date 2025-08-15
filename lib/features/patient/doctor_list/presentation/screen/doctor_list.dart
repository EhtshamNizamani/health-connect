import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_bloc.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_event.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_state.dart';
import 'package:health_connect/features/patient/home/presentation/widgets/doctor_card.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final _scrollController = ScrollController();
  late final DoctorListBloc _doctorListBloc;

  @override
  void initState() {
    super.initState();
    // Create the BLoC instance and add the initial event
    _doctorListBloc = sl<DoctorListBloc>()..add(FetchInitialDoctors());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _doctorListBloc.close(); // Important to close the BLoC
    super.dispose();
  }

  /// Checks if the user is near the bottom of the list to fetch more data.
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _doctorListBloc.add(FetchMoreDoctors());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Doctors"),
      ),
      // Use BlocProvider.value to provide the existing BLoC instance to the widget tree
      body: BlocProvider.value(
        value: _doctorListBloc,
        child: BlocBuilder<DoctorListBloc, DoctorListState>(
          builder: (context, state) {
            // Case 1: Initial loading state
            if (state.isLoadingFirstPage) {
              return const Center(child: CircularProgressIndicator());
            }

            // Case 2: Error state
            if (state.errorMessage != null && state.doctors.isEmpty) {
              return Center(child: Text(state.errorMessage!));
            }

            // Case 3: Empty list state
            if (state.doctors.isEmpty) {
              return const Center(child: Text("No doctors found."));
            }

            // Case 4: The main list view with data
            return RefreshIndicator(
              onRefresh: () async {
                _doctorListBloc.add(FetchInitialDoctors());
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                // Item count is the number of doctors + 1 if there's more to load
                itemCount: state.hasReachedMax
                    ? state.doctors.length
                    : state.doctors.length + 1,
                itemBuilder: (context, index) {
                  // If it's the last item and we have more pages, show a loading indicator
                  if (index >= state.doctors.length) {
                    return state.isLoadingMore
                        ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                        : const SizedBox.shrink();
                  }
                  
                  // Otherwise, show the DoctorCard
                  return DoctorCard(doctor: state.doctors[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}