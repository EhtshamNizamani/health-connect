import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/constants/app_color.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import '../bloc/doctor_appointments_bloc.dart';
import '../bloc/doctor_appointments_event.dart';
import '../bloc/doctor_appointments_state.dart';
import '../widgets/appointment_card.dart';

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
                    _buildAppointmentList(context, state.pending),
                    _buildAppointmentList(context, state.upcoming),
                    _buildAppointmentList(context, state.past),
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

  Widget _buildAppointmentList(
    BuildContext context,
    List<AppointmentEntity> appointments,
  ) {
    if (appointments.isEmpty) {
      return const Center(child: Text("No appointments in this category."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: appointments.length,
      itemBuilder: (ctx, index) {
        final appointment = appointments[index];
        return AppointmentCard(
          appointment: appointment,
          // Pending actions
          onConfirm: appointment.status == 'pending'
              ? () => context.read<DoctorAppointmentsBloc>().add(ConfirmAppointment(appointment.id))
              : null,
          onCancel: appointment.status == 'pending'
              ? () => context.read<DoctorAppointmentsBloc>().add(CancelAppointment(appointment.id))
              : null,
          
          // --- NAYE ACTIONS FOR PAST APPOINTMENTS ---
          onMarkAsCompleted: appointment.status == 'confirmed'
              ? () => context.read<DoctorAppointmentsBloc>().add(CompletedAppointment(appointment.id))
              : null,
          onMarkAsNoShow: appointment.status == 'confirmed'
              ? () => context.read<DoctorAppointmentsBloc>().add(CancelAppointment(appointment.id))
              : null,
        );
      },
    );
  }
}
