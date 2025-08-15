import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/doctor/review/presantation/screen/review_screen.dart';
import '../bloc/patient_appointments_bloc.dart';
import '../bloc/patient_appointments_event.dart';
import '../bloc/patient_appointments_state.dart';
import '../../../doctor_profile_view/presantion/widget/patient_appointment_card.dart';

class PatientAppointmentsScreen extends StatelessWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PatientAppointmentsBloc>()..add(FetchPatientAppointments()),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("My Appointments"),
            bottom:  TabBar(
               labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
              ),
              tabs: [
                Tab(text: "Upcoming"),
                Tab(text: "Past"),
              ],
            ),
          ),
          body: BlocBuilder<PatientAppointmentsBloc, PatientAppointmentsState>(
            builder: (context, state) {
              if (state is PatientAppointmentsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is PatientAppointmentsError) {
                return Center(child: Text(state.message));
              }
              if (state is PatientAppointmentsLoaded) {
                return TabBarView(
                  children: [
                    _buildAppointmentList(context, state.upcoming),
                    _buildAppointmentList(context, state.past),
                  ],
                );
              }
              return const Center(child: Text("You have no appointments."));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(BuildContext context, List<AppointmentEntity> appointments) {
    if (appointments.isEmpty) {
      return const Center(child: Text("No appointments in this category."));
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PatientAppointmentsBloc>().add(FetchPatientAppointments());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: appointments.length,
        itemBuilder: (ctx, index) {
          final appointment = appointments[index];
          return PatientAppointmentCard(
            appointment: appointment,
            onCancel: () {
              // Show a confirmation dialog before cancelling
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text("Confirm Cancellation"),
                  content: const Text("Are you sure you want to cancel this appointment?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("No")),
                    TextButton(
                      onPressed: () {
                        context.read<PatientAppointmentsBloc>().add(CancelPatientAppointment(appointment.id));
                        Navigator.pop(dialogContext);
                      },
                      child: const Text("Yes, Cancel"),
                    ),
                  ],
                ),
              );
            },
            onRate: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddReviewScreen(doctorId: appointment.doctorId,appointmentId:appointment.id)));
            },
          );
        },
      ),
    );
  }
}