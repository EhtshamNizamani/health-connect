
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/doctor/appointment/presantation/bloc/doctor_appointments_bloc.dart';
import 'package:health_connect/features/doctor/appointment/presantation/bloc/doctor_appointments_event.dart';
import 'package:health_connect/features/doctor/appointment/presantation/bloc/doctor_appointments_state.dart';
import 'package:health_connect/features/doctor/appointment/presantation/widgets/appointment_card.dart';

class AppointmentListView extends StatelessWidget {
  final DoctorAppointmentsLoaded state;
  final List<AppointmentEntity> appointments;
  
  const AppointmentListView({
    super.key,
    required this.state,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    // Agar list khali hai, to RefreshIndicator ke andar message dikhayein
    // taaki user khali screen ko bhi refresh kar sake.
    if (appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<DoctorAppointmentsBloc>().add(FetchDoctorAppointments());
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: const Center(child: Text("No appointments in this category.")),
              ),
            );
          }
        ),
      );
    }

    // --- MAIN PULL-TO-REFRESH LOGIC ---
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DoctorAppointmentsBloc>().add(FetchDoctorAppointments());
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        itemCount: appointments.length,
        itemBuilder: (ctx, index) {
          final appointment = appointments[index];
          return AppointmentCard(
            appointment: appointment,
            isUpdating: state.updatingAppointmentId == appointment.id,
            // Pending actions
            onConfirm: appointment.status == 'pending'
                ? () => context
                    .read<DoctorAppointmentsBloc>()
                    .add(ConfirmAppointment(appointment.id))
                : null,
            onCancel: appointment.status == 'pending'
                ? () => context
                    .read<DoctorAppointmentsBloc>()
                    .add(CancelAppointment(appointment.id))
                : null,
            // Confirmed actions
            onMarkAsCompleted: appointment.status == 'confirmed'
                ? () => context
                    .read<DoctorAppointmentsBloc>()
                    .add(CompletedAppointment(appointment.id))
                : null,
            onMarkAsNoShow: appointment.status == 'confirmed'
                ? () => context
                    .read<DoctorAppointmentsBloc>()
                    .add(MarkAsNoShow(appointment.id))
                : null,
          );
        },
      ),
    );
  }
}