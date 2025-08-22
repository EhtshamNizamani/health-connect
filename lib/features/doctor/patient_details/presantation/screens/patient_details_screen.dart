import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/core/utils/next_upcoming_appointment.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/screens/appoiontment_details_screen.dart';
import 'package:health_connect/features/doctor/patient_details/presantation/bloc/patient_details_bloc.dart';
import 'package:health_connect/features/doctor/patient_details/presantation/bloc/patient_details_event.dart';
import 'package:health_connect/features/doctor/patient_details/presantation/bloc/patient_details_state.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';


class PatientDetailScreen extends StatelessWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PatientDetailBloc>()..add(FetchPatientDetails(patientId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Patient Details'),
        ),
        // --- THE CORRECT STRUCTURE ---
        // DefaultTabController wraps the BlocBuilder.
        body: DefaultTabController(
          length: 4,
          child: BlocBuilder<PatientDetailBloc, PatientDetailState>(
            builder: (context, state) {
              // --- LOADING STATE ---
              if (state is PatientDetailLoading || state is PatientDetailInitial) {
                // The skeleton now has access to the TabController.
                return const _PatientDetailSkeleton();
              }
              // --- ERROR STATE ---
              if (state is PatientDetailError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(state.message, textAlign: TextAlign.center),
                  ),
                );
              }
              // --- LOADED STATE ---
              if (state is PatientDetailLoaded) {
                final details = state.details;
                final patient = details.patient;
                final appointments = details.allAppointments;
                final upcomingAppointment = findNextUpcomingAppointment(appointments);

                return Column(
                  children: [
                    _PatientHeader(patient: patient),
                    const TabBar(
                      tabs: [
                        Tab(icon: Icon(CupertinoIcons.person_fill), text: 'Overview'),
                        Tab(icon: Icon(CupertinoIcons.calendar), text: 'History'),
                        Tab(icon: Icon(CupertinoIcons.pencil_ellipsis_rectangle), text: 'Notes'),
                        Tab(icon: Icon(CupertinoIcons.folder_fill), text: 'Files'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _OverviewTab(patient: patient, upcomingAppointment: upcomingAppointment),
                          _AppointmentHistoryTab(appointments: appointments),
                          _NotesTab(appointments: appointments),
                          _FilesTab(appointments: appointments),
                        ],
                      ),
                    ),
                  ],
                );
              }
              // --- FALLBACK STATE ---
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

// --- SKELETON LOADER WIDGET ---
class _PatientDetailSkeleton extends StatelessWidget {
  const _PatientDetailSkeleton();
  
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(radius: 35, backgroundColor: Colors.white),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 24, width: 150, color: Colors.white, margin: const EdgeInsets.only(bottom: 8)),
                    Container(height: 16, width: 80, color: Colors.white),
                  ],
                )
              ],
            ),
          ),
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Overview'),
              Tab(icon: Icon(Icons.calendar_today), text: 'History'),
              Tab(icon: Icon(Icons.notes), text: 'Notes'),
              Tab(icon: Icon(Icons.folder), text: 'Files'),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(height: 20, width: 200, color: Colors.white, margin: const EdgeInsets.only(bottom: 12)),
                   Container(height: 80, width: double.infinity, color: Colors.white, margin: const EdgeInsets.only(bottom: 24)),
                   Container(height: 20, width: 150, color: Colors.white, margin: const EdgeInsets.only(bottom: 12)),
                   Container(height: 120, width: double.infinity, color: Colors.white),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- WIDGETS FOR THE MAIN SCREEN LAYOUT ---

class _PatientHeader extends StatelessWidget {
  final UserEntity patient;
  const _PatientHeader({required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: (patient.photoUrl != null && patient.photoUrl!.isNotEmpty)
                ? CachedNetworkImageProvider(patient.photoUrl!)
                : null,
            child: (patient.photoUrl == null || patient.photoUrl!.isEmpty)
                ? Text(patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?')
                : null,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient.name,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
             Text(
                "${patient.age ?? ''}${patient.age != null && patient.gender != null ? ', ' : ''}${patient.gender ?? ''}",
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(CupertinoIcons.chat_bubble_2, size: 28),
            onPressed: () {
              // TODO: Navigate to chat screen with this patient
            },
            color: theme.colorScheme.primary,
          )
        ],
      ),
    );
  }
}

// --- WIDGETS FOR EACH TAB ---

class _OverviewTab extends StatelessWidget {
  final UserEntity patient;
  final AppointmentEntity? upcomingAppointment;
  const _OverviewTab({required this.patient, this.upcomingAppointment});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle("Next Appointment"),
          const SizedBox(height: 12),
          if (upcomingAppointment != null)
            _AppointmentCard(appointment: upcomingAppointment!)
          else
            const Text("No upcoming appointments scheduled."),
          const SizedBox(height: 24),
          const _SectionTitle("Patient Snapshot"),
           const SizedBox(height: 12),
          _SnapshotCard(patient: patient),
        ],
      ),
    );
  }
}

class _AppointmentHistoryTab extends StatelessWidget {
  final List<AppointmentEntity> appointments;
  const _AppointmentHistoryTab({required this.appointments});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const Center(child: Text("No appointment history."));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: appointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _AppointmentCard(appointment: appointments[index]);
      },
    );
  }
}

class _NotesTab extends StatelessWidget {
  final List<AppointmentEntity> appointments;
  const _NotesTab({required this.appointments});
  
  @override
  Widget build(BuildContext context) {
    final appointmentsWithNotes = appointments.where((a) => a.doctorNotes != null && a.doctorNotes!.isNotEmpty).toList();
    if (appointmentsWithNotes.isEmpty) {
      return const Center(child: Text("No notes found for this patient."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: appointmentsWithNotes.length,
      itemBuilder: (context, index) {
        final appointment = appointmentsWithNotes[index];
        return Card(
          child: ListTile(
            title: Text("Note from ${DateFormat('d MMM, yyyy').format(appointment.appointmentDateTime)}"),
            subtitle: Text(appointment.doctorNotes!, maxLines: 3, overflow: TextOverflow.ellipsis),
            onTap: () {
              // TODO: Open a dialog or screen to show the full note
            },
          ),
        );
      },
    );
  }
}

class _FilesTab extends StatelessWidget {
  final List<AppointmentEntity> appointments;
  const _FilesTab({required this.appointments});

  @override
  Widget build(BuildContext context) {
    final allFiles = appointments.expand((a) => a.attachedFiles).toList();
     if (allFiles.isEmpty) {
      return const Center(child: Text("No files found for this patient."));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12
      ),
      itemCount: allFiles.length,
      itemBuilder: (context, index){
        final file = allFiles[index];
        return Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(file.fileName.endsWith('.pdf') ? CupertinoIcons.doc_text_fill : CupertinoIcons.photo_fill, size: 40),
              const SizedBox(height: 8),
              Text(file.fileName, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }
}

// --- REUSABLE HELPER WIDGETS ---

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(DateFormat('d MMMM, yyyy  -  hh:mm a').format(appointment.appointmentDateTime)),
        subtitle: Text("Status: ${appointment.status}"),
        trailing: const Icon(CupertinoIcons.chevron_right),
        onTap: () {
          // Navigate to the AppointmentDetailScreen for this specific appointment
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => AppointmentDetailScreen(appointmentId: appointment.id),
          ));
        },
      ),
    );
  }
}
class _SnapshotCard extends StatelessWidget {
  final UserEntity patient;
  const _SnapshotCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // <<< --- THE FINAL CHANGE ---
            _InfoRow(
              title: "Allergies",
              value: patient.allergies?.isNotEmpty == true ? patient.allergies! : "None Reported",
            ),
            const Divider(height: 24),
            _InfoRow(
              title: "Chronic Conditions",
              value: patient.chronicConditions?.isNotEmpty == true ? patient.chronicConditions! : "None Reported",
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _InfoRow({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title:",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }
}