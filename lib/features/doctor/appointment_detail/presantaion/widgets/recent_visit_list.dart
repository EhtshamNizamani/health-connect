// --- WIDGET #5: Recent Visits List ---
import 'package:flutter/material.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/doctor/past_appointment_summary/presentation/screens/past_appointment_summary_screen.dart';
import 'package:intl/intl.dart';

class RecentVisitsList extends StatelessWidget {
  const RecentVisitsList({super.key, required this.visits});
final List<AppointmentEntity> visits;
  @override
  Widget build(BuildContext context){
    final theme = Theme.of(context);

    if (visits.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: const Text("No previous visits found for this patient."),
      );
    }

    return ListView.builder(
      
      // ListView.builder ko extra padding ki zaroorat nahi agar parent de raha hai
      padding: EdgeInsets.zero,
      itemCount: visits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // --- THE FIX ---
        // 'visit' ab ek AppointmentEntity object hai, Map nahi.
        final AppointmentEntity visit = visits[index];
        final String status = visit.status; // Use dot notation: visit.status
        final Color statusColor = _getStatusColor(status, theme);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.dividerColor),
          ),
          child: InkWell(
            onTap: () {
              // Yahan aap is pichle appointment ki detail screen par navigate kar sakte hain
Navigator.push(context, MaterialPageRoute(builder: (context)=> PastAppointmentSummaryScreen(appointment: visit)));            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with Date and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // Use dot notation: visit.appointmentDateTime
                        DateFormat('d MMMM, yyyy').format(visit.appointmentDateTime),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // A small, colored status chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          // status ko capitalize karein
                          status.substring(0, 1).toUpperCase() + status.substring(1),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Note Preview
                  // Abhi ke liye humare AppointmentEntity mein 'note_preview' nahi hai.
                  // Hum ise aage add kar sakte hain. Abhi ke liye इसे hata dete hain.
                  // Ya ek placeholder dikha sakte hain.
                  Text(
                    'Tap to view details for this visit.', // Placeholder text
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
Color _getStatusColor(String status, ThemeData theme) {
  switch (status.toLowerCase()) { 
    case 'completed':
      return theme.colorScheme.primary;
    case 'cancelled':
      return theme.colorScheme.error;
    case 'no-show':
      return Colors.orange.shade800;
    default:
      return theme.colorScheme.outline;
  }
}
}

