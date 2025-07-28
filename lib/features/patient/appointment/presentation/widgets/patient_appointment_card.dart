import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:intl/intl.dart';
typedef OnRateCallback = void Function();

class PatientAppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback? onCancel;
  final OnRateCallback? onRate; // Nayi callback

  const PatientAppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
    this.onRate, // Nayi callback ko constructor mein add karein
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
            // --- Top Section (Doctor Info & Status) ---
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: appointment.doctorPhotoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(appointment.doctorPhotoUrl)
                      : null, // Handle empty URL
                  child: appointment.doctorPhotoUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.doctorName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEE, MMM d, yyyy • hh:mm a').format(appointment.appointmentDateTime),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(appointment.status, theme),
              ],
            ),

            // --- Action Area (Neeche ka hissa) ---
            // Ye widget decide karega ki kaunsa button dikhana hai
            _buildActionArea(context),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the status chip
  Widget _buildStatusChip(String status, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getStatusColor(status, theme).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(status, theme),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper widget to build the action area based on status
  Widget _buildActionArea(BuildContext context) {
    final theme = Theme.of(context);
    final status = appointment.status;

    // Condition 1: Agar 'pending' ya 'confirmed' hai, to "Cancel" button dikhayein
    if ((status == 'pending' || status == 'confirmed') && onCancel != null) {
      return Column(
        children: [
          const Divider(height: 24, thickness: 1),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onCancel,
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text("Cancel Appointment"),
            ),
          ),
        ],
      );
    }
    // Condition 2: Agar 'completed' hai AUR review nahi diya gaya hai
    else if (status == 'completed' && !appointment.isReviewed && onRate != null) {
      return Column(
        children: [
          const Divider(height: 24, thickness: 1),
          Align(
            alignment: Alignment.centerRight,
            // FilledButton ka istemaal karein taaki ye zyada important lage
            child: FilledButton.icon(
              onPressed: onRate,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              icon: const Icon(Icons.star_outline, size: 18),
              label: const Text("Rate Doctor"),
            ),
          ),
        ],
      );
    }
    // Condition 3: Agar 'completed' hai AUR review de diya gaya hai
    else if (status == 'completed' && appointment.isReviewed) {
      return Column(
        children: [
          const Divider(height: 24, thickness: 1),
          Align(
            alignment: Alignment.centerRight,
            // Bas ek confirmation message dikhayein
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text("Review Submitted", style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      );
    }
    // Baaki ke cases (jaise 'cancelled') ke liye kuch na dikhayein
    else {
      return const SizedBox.shrink(); // Empty space
    }
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
