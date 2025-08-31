import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/widgets/info_row.dart';

class PatientSnapshotCard extends StatelessWidget {
  final UserEntity patient;
  
  /// The specific appointment being viewed, to get the last visit note.
  /// We make this nullable in case there is no relevant appointment.
  final AppointmentEntity? appointment;
  
  const PatientSnapshotCard({
    super.key, 
    required this.patient,
    this.appointment, // Make it optional
  });
  
  @override
  Widget build(BuildContext context) {
    // Determine the last visit note. It comes from the current appointment's details.
    final String lastVisitNote = appointment?.doctorNotes?.isNotEmpty == true 
      ? appointment!.doctorNotes! 
      : "No notes added for this visit yet.";

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- DYNAMIC DATA ---
            InfoRowWithIcon(
              title: "Allergies",
              // Use real data from the patient entity
              value: patient.allergies?.isNotEmpty == true
                  ? patient.allergies!
                  : "None Reported",
            ),
            const Divider(height: 24),
            InfoRowWithIcon(
              title: "Chronic Condition",
              // Use real data from the patient entity
              value: patient.chronicConditions?.isNotEmpty == true
                  ? patient.chronicConditions!
                  : "None Reported",
            ),
            const Divider(height: 24),
            InfoRowWithIcon(
              title: "Last Visit Note",
              // Use real data from the appointment entity
              value: lastVisitNote,
            ),
          ],
        ),
      ),
    );
  }
}