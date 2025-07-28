import 'package:flutter/material.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  // --- NAYI CALLBACKS ---
  final VoidCallback? onMarkAsCompleted;
  final VoidCallback? onMarkAsNoShow;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onConfirm,
    this.onCancel,
    this.onMarkAsCompleted,
    this.onMarkAsNoShow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Section (Patient Info & Status) ---
            Row(
              children: [
                CircleAvatar(
                  child: Text(appointment.patientName.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('EEE, MMM d, yyyy • hh:mm a').format(appointment.appointmentDateTime),
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
            
            // --- NAYA, SMART ACTION AREA ---
            _buildActionArea(context),
          ],
        ),
      ),
    );
  }

  // Helper widget to decide which buttons to show
  Widget _buildActionArea(BuildContext context) {
    final status = appointment.status;
    final isPast = appointment.appointmentDateTime.isBefore(DateTime.now());

    // Case 1: Pending Requests
    if (status == 'pending') {
      return Column(
        children: [
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
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
      );
    }
    
    // Case 2: Confirmed appointments that are now in the past
    // and need to be marked as completed or no-show.
    if (status == 'confirmed' && isPast) {
      return Column(
        children: [
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onMarkAsNoShow,
                child: const Text("No-Show"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onMarkAsCompleted,
                child: const Text("Mark Completed"),
              ),
            ],
          ),
        ],
      );
    }

    // For all other cases (upcoming-confirmed, completed, cancelled), show nothing.
    return const SizedBox.shrink();
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'pending': return Colors.orange.shade700;
      case 'confirmed': return Colors.green.shade700;
      case 'cancelled': return theme.colorScheme.error;
      case 'completed': return theme.colorScheme.primary;
      default: return theme.colorScheme.outline;
    }
  }
}