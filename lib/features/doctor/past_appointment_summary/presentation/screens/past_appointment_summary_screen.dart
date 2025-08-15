import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/domain/entities/prescription_item_entity.dart';
import 'package:health_connect/features/appointment/domain/entities/attached_file_entity.dart';
import 'package:intl/intl.dart';

class PastAppointmentSummaryScreen extends StatelessWidget {
  final AppointmentEntity appointment;
  
  const PastAppointmentSummaryScreen({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
  title: const Text("Visit Summary"),
  backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
  foregroundColor: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
  elevation: theme.appBarTheme.elevation ?? 0,
  centerTitle: theme.appBarTheme.centerTitle ?? false,
  titleTextStyle: theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.w600,
    color: theme.colorScheme.onSurface,
  ),
  iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(
    color: theme.colorScheme.onSurface,
  ),
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section 1: The Basic Info Card you already have ---
            _buildHeaderCard(context, theme),
            const SizedBox(height: 32),

            // --- Section 2: Doctor's Notes (The most important part) ---
            // Yeh section sirf tabhi dikhega jab notes maujood hon
            if (appointment.doctorNotes != null && appointment.doctorNotes!.isNotEmpty) ...[
              const _SectionTitle(title: "Your Notes from this Visit"),
              const SizedBox(height: 16),
              _NotesCard(notes: appointment.doctorNotes!),
              const SizedBox(height: 32),
            ] else ... [
              // Agar notes nahi hain, to ek message dikhayein
              _EmptyStateCard(
                icon: CupertinoIcons.pencil_ellipsis_rectangle,
                message: "No notes were added for this visit.",
              ),
              const SizedBox(height: 32),
            ],

            // --- Section 3: Prescription Issued ---
            if (appointment.prescription.isNotEmpty) ...[
              const _SectionTitle(title: "Prescription Issued"),
              const SizedBox(height: 16),
              _PrescriptionList(prescription: appointment.prescription),
              const SizedBox(height: 32),
            ],

            // --- Section 4: Attached Files ---
            if (appointment.attachedFiles.isNotEmpty) ...[
              const _SectionTitle(title: "Attached Files"),
              const SizedBox(height: 16),
              _AttachedFilesGrid(files: appointment.attachedFiles),
            ],
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeaderCard(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 2,
      shadowColor: theme.shadowColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _InfoRow(
              context: context,
              label: "Date",
              value: DateFormat('d MMMM, yyyy').format(appointment.appointmentDateTime),
              icon: CupertinoIcons.calendar,
            ),
            Divider(height: 24, color: theme.dividerColor),
            _InfoRow(
              context: context,
              label: "Patient",
              value: appointment.patientName,
              icon: CupertinoIcons.person_fill,
            ),
            Divider(height: 24, color: theme.dividerColor),
            Row(
              children: [
                Icon(
                  CupertinoIcons.check_mark_circled, 
                  color: theme.colorScheme.onSurfaceVariant, 
                  size: 20
                ),
                const SizedBox(width: 12),
                Text(
                  "Status", 
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold, 
                    color: theme.colorScheme.onSurfaceVariant
                  )
                ),
                const Spacer(),
                _StatusChip(status: appointment.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
       elevation: 0,
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          notes, 
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurface
          )
        ),
      ),
    );
  }
}

class _PrescriptionList extends StatelessWidget {
  final List<PrescriptionItemEntity> prescription;
  const _PrescriptionList({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: ListView.separated(
        itemCount: prescription.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        separatorBuilder: (context, index) => Divider(
          height: 1, 
          indent: 16, 
          color: theme.dividerColor
        ),
        itemBuilder: (context, index) {
          final item = prescription[index];
          return ListTile(
            leading: Icon(
              CupertinoIcons.pin, 
              color: theme.colorScheme.primary.withOpacity(0.7)
            ),
            title: Text(
              item.medicine, 
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface
              )
            ),
            subtitle: Text(
              item.dosage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant
              )
            ),
          );
        },
      ),
    );
  }
}

class _AttachedFilesGrid extends StatelessWidget {
  final List<AttachedFileEntity> files;
  const _AttachedFilesGrid({required this.files});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: files.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final file = files[index];
        return InkWell(
          onTap: () {
            // TODO: Open the file URL
            print("Opening file: ${file.url}");
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  file.fileName.endsWith('.pdf') 
                    ? CupertinoIcons.doc_text_fill 
                    : CupertinoIcons.photo_fill,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    file.fileName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color;
    final String text;

    switch (status.toLowerCase()) {
      case 'completed':
        color = theme.colorScheme.primary;
        text = 'Completed';
        break;
      case 'cancelled':
        color = theme.colorScheme.error;
        text = 'Cancelled';
        break;
      case 'no-show':
        color = theme.colorScheme.tertiary;
        text = 'No-Show';
        break;
      default:
        color = theme.colorScheme.outline;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final BuildContext context;
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({required this.context, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold, 
            color: theme.colorScheme.onSurfaceVariant
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface
          ),
        ),
      ],
    );
  }
}

// Naya widget agar koi section khali ho
class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyStateCard({required this.icon, required this.message});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
       elevation: 0,
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor, style: BorderStyle.solid),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                icon, 
                size: 32, 
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6)
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Helper Widgets ---

// WIDGET 1: Section Title
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface
        ),
      ),
    );
  }
}