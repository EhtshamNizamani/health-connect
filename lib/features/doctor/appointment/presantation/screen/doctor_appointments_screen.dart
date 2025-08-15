import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/doctor/appointment/presantation/widgets/appointment_list_view.dart';
import '../bloc/doctor_appointments_bloc.dart';
import '../bloc/doctor_appointments_event.dart';
import '../bloc/doctor_appointments_state.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<DoctorAppointmentsBloc>()..add(FetchDoctorAppointments()),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("My Appointments"),
            automaticallyImplyLeading: false,
            bottom: TabBar(
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
              ),
              tabs: [
                Tab(text: "Pending"),
                Tab(text: "Upcoming"),
                Tab(text: "Past/Cancelled"),
              ],
            ),
          ),
          body: BlocBuilder<DoctorAppointmentsBloc, DoctorAppointmentsState>(
            builder: (context, state) {
              if (state is DoctorAppointmentsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DoctorAppointmentsError) {
                return Center(child: Text(state.message));
              }
              if (state is DoctorAppointmentsLoaded) {
                return TabBarView(
                  children: [
                   AppointmentListView(
                      state: state,
                      appointments: state.pending,
                    ),
                    AppointmentListView(
                      state: state,
                      appointments: state.upcoming,
                    ),
                    AppointmentListView(
                      state: state,
                      appointments: state.past,
                    ),
                  ],
                );
              }
              return const Center(child: Text("No appointments found."));
            },
          ),
        ),
      ),
    );
  }
}
