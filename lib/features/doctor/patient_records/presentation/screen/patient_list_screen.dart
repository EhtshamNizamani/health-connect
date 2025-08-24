import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/screens/appoiontment_details_screen.dart';
import 'package:health_connect/features/doctor/patient_details/presantation/screens/patient_details_screen.dart';
import 'package:health_connect/features/doctor/patient_records/domain/entity/patient_record_entity.dart';
import 'package:health_connect/features/doctor/patient_records/presentation/bloc/patient_records_bloc.dart';
import 'package:health_connect/features/doctor/patient_records/presentation/bloc/patient_records_event.dart';
import 'package:health_connect/features/doctor/patient_records/presentation/bloc/patient_records_state.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PatientRecordsBloc>()..add(FetchPatientRecords()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Patient Records"),
        ),
        body: RefreshIndicator(
          onRefresh: ()async {
            context.read<PatientRecordsBloc>().add(FetchPatientRecords());
          },
          child: Column(
            children: [
              // Section 1: Search Bar and Filters
              const Padding(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: _SearchAndFilterSection(),
              ),
              const SizedBox(height: 16),
              
              // Section 2: Patient List (conditionally rendered)
              Expanded(
                child: BlocBuilder<PatientRecordsBloc, PatientRecordsState>(
                  builder: (context, state) {
                    if (state is PatientRecordsLoading || state is PatientRecordsInitial) {
                      return const _PatientListSkeleton();
                    }
                    if (state is PatientRecordsError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is PatientRecordsLoaded) {
                      return _PatientList(patients: state.filteredPatients);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// --- WIDGET #1: Search and Filter Section ---
class _SearchAndFilterSection extends StatefulWidget {
  const _SearchAndFilterSection();
  @override
  State<_SearchAndFilterSection> createState() => _SearchAndFilterSectionState();
}

class _SearchAndFilterSectionState extends State<_SearchAndFilterSection> {
  final List<String> _filters = ["Recently Active", "A-Z"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Listen to the BLoC state to set the selected chip
    final activeFilter = context.select((PatientRecordsBloc bloc) =>
        bloc.state is PatientRecordsLoaded ? (bloc.state as PatientRecordsLoaded).activeFilter : "Recently Active");

    return Column(
      children: [
        CupertinoSearchTextField(
          placeholder: 'Search patient by name...',
          onChanged: (value) {
            context.read<PatientRecordsBloc>().add(SearchQueryChanged(value));
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _filters[index];
              return ChoiceChip(
                label: Text(filter),
                selected: activeFilter == filter,
                onSelected: (isSelected) {
                  if (isSelected) {
                    context.read<PatientRecordsBloc>().add(FilterChanged(filter));
                  }
                },
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primaryContainer,
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- WIDGET #2: The main list of patients ---
class _PatientList extends StatelessWidget {
  final List<PatientRecordEntity> patients;
  const _PatientList({required this.patients});

  @override
  Widget build(BuildContext context) {
    if (patients.isEmpty) {
      return const Center(child: Text("No patient records found."));
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: patients.length,
      separatorBuilder: (context, index) => const Divider(height: 8),
      itemBuilder: (context, index) {
        final patientRecord = patients[index];
        return _PatientListItem(patientRecord: patientRecord);
      },
    );
  }
}

// --- WIDGET #3: A single item in the patient list ---
class _PatientListItem extends StatelessWidget {
  final PatientRecordEntity patientRecord;
  const _PatientListItem({required this.patientRecord});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patient = patientRecord.patient;

    return ListTile(
      
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: theme.colorScheme.primaryContainer,
        backgroundImage: (patient.photoUrl != null && patient.photoUrl!.isNotEmpty)
            ? CachedNetworkImageProvider(patient.photoUrl!)
            : null,
        child: (patient.photoUrl == null || patient.photoUrl!.isEmpty)
            ? Text(
                patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
              )
            : null,
      ),
      title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        patientRecord.lastVisit != null
          ? "Last Visit: ${DateFormat('d MMM, yyyy').format(patientRecord.lastVisit!)}"
          : "No appointments yet",
        style: theme.textTheme.bodySmall,
      ),
      trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.grey),
      onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PatientDetailScreen(patientId: patient.id,)));
      },
    );
  }
}


// --- WIDGET #4: Skeleton Loader for the list ---
class _PatientListSkeleton extends StatelessWidget {
  const _PatientListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: 8, // Show 8 skeleton items
        separatorBuilder: (context, index) => const Divider(height: 8),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            leading: const CircleAvatar(radius: 28, backgroundColor: Colors.white),
            title: Container(height: 16, width: 150, color: Colors.white),
            subtitle: Container(height: 12, width: 100, color: Colors.white),
            trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.white),
          );
        },
      ),
    );
  }
}