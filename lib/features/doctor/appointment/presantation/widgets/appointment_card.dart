import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/screens/appoiontment_details_screen.dart';
import 'package:health_connect/features/patient/appointment/presentation/screen/patient_appointment_screen.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final bool isUpdating; // Flag to show a loader on this specific card
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onMarkAsCompleted;
  final VoidCallback? onMarkAsNoShow;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.isUpdating = false, // Default to false
    this.onConfirm,
    this.onCancel,
    this.onMarkAsCompleted,
    this.onMarkAsNoShow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AppointmentDetailScreen(appointmentId: appointment.id,))),
      child: Card(
        
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
                  // Use patient's photo if available, otherwise initials
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: appointment.doctorPhotoUrl.isNotEmpty
                        ? CachedNetworkImageProvider(appointment.doctorPhotoUrl)
                        : null,
                    child: appointment.doctorPhotoUrl.isEmpty
                        ? Text(
                            appointment.patientName.isNotEmpty
                                ? appointment.patientName
                                      .substring(0, 1)
                                      .toUpperCase()
                                : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.patientName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'EEE, MMM d, yyyy • hh:mm a',
                          ).format(appointment.appointmentDateTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(appointment.status, theme),
                ],
              ),
      
              // --- Smart Action Area ---
              _buildActionArea(context),
            ],
          ),
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

  // Helper widget to decide which buttons to show or if a loader is needed
  Widget _buildActionArea(BuildContext context) {

    final theme = Theme.of(context);

    // If any action callback is provided, it means this card is actionable.
    final isActionable =
        onConfirm != null ||
        onCancel != null ||
        onMarkAsCompleted != null ||
        onMarkAsNoShow != null;

    if (!isActionable) {
      return const SizedBox.shrink(); // No actions, show nothing.
    }

    // --- Main Logic: Show loader or buttons ---
    return Column(
      children: [
        const Divider(height: 24, thickness: 1),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isUpdating
              // State 1: Show a loader with message
              ? _buildLoadingState(theme)
              // State 2: Show the relevant buttons
              : _buildButtonRow(context, theme),
        ),
      ],
    );
  }

  // New: Loading state with better UX
  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      key: const ValueKey('loading'), // Key for AnimatedSwitcher
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Updating appointment...",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build the correct row of buttons based on status
  Widget _buildButtonRow(BuildContext context, ThemeData theme) {
    return Container(
      key: const ValueKey('buttons'), // Key for AnimatedSwitcher
      child: _getButtonsForStatus(context, theme),
    );
  }

  Widget _getButtonsForStatus(BuildContext context, ThemeData theme) {
    // Case 1: Pending Requests
    if (appointment.status == 'pending') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: isUpdating ? null : onCancel, // Disable if updating
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            icon: Icon(Icons.close, size: 18),
            label: const Text("Reject"),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: isUpdating ? null : onConfirm, // Disable if updating
            icon: Icon(Icons.check, size: 18),
            label: const Text("Confirm"),
          ),
        ],
      );
    }

    // Case 2: Confirmed appointments that need to be marked as completed or no-show.
    if (appointment.status == 'confirmed') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: isUpdating ? null : onMarkAsNoShow,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            icon: Icon(Icons.person_off, size: 18),
            label: const Text("No-Show"),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: isUpdating ? null : onMarkAsCompleted,
            icon: Icon(Icons.check_circle, size: 18),
            label: const Text("Mark as Done"),
          ),
        ],
      );
    }

    // Fallback for any other case (should not happen if logic is correct)
    return const SizedBox.shrink();
  }

  Color _getStatusColor(String status, ThemeData theme) {
    print('this is status $status');
    switch (status) {
      case 'pending':
        return Colors.orange.shade700;
      case 'confirmed':
        return Colors.green.shade700;
      case 'cancelled':
        return theme.colorScheme.error;
      case 'no-show':
        return theme.colorScheme.error.withAlpha(160);
      case 'completed':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.outline;
    }
  }
}
