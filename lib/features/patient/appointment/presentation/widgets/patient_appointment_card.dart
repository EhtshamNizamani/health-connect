import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:intl/intl.dart';

class PatientAppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback? onCancel;

  const PatientAppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canCancel = appointment.status == 'pending' || appointment.status == 'confirmed';

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: CachedNetworkImageProvider(appointment.doctorPhotoUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.doctorName, style: theme.textTheme.titleMedium),
                      Text(
                        DateFormat('EEE, MMM d, yyyy • hh:mm a').format(appointment.appointmentDateTime),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  appointment.status.toUpperCase(),
                  style: TextStyle(color: _getStatusColor(appointment.status, theme), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (canCancel) ...[
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                  child: const Text("Cancel Appointment"),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.green;
      case 'cancelled': return theme.colorScheme.error;
      case 'completed': return theme.colorScheme.outline;
      default: return theme.colorScheme.outline;
    }
  }
}