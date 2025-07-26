import 'package:flutter/material.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = appointment.status == 'pending';

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
                  // You can add patient photo here later if you store it
                  child: Text(appointment.patientName.substring(0, 1)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        DateFormat(
                          'EEE, MMM d, yyyy • hh:mm a',
                        ).format(appointment.appointmentDateTime),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  appointment.status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(appointment.status, theme),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (isPending) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onCancel,
                    child: const Text("Reject"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onConfirm,
                    child: const Text("Confirm"),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return theme.colorScheme.error;
      case 'completed':
        return theme.colorScheme.outline;
      default:
        return theme.colorScheme.outline;
    }
  }
}
