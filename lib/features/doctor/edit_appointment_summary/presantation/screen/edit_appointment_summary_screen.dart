import 'dart:io';
import 'dart:ui' as BorderType;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/domain/entities/prescription_item_entity.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/presantation/bloc/edit_summary_bloc.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/presantation/widgets/attach_file_list.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/presantation/widgets/prescription_list.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/presantation/widgets/section_title.dart';

class EditAppointmentSummaryScreen extends StatelessWidget {
  final AppointmentEntity appointment;
  const EditAppointmentSummaryScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<EditSummaryBloc>()..add(InitializeSummary(appointment)),
      child: BlocConsumer<EditSummaryBloc, EditSummaryState>(
        listener: (context, state) {
          // Listen for success or failure states to show feedback
          if (state.status == EditSummaryStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Summary saved successfully!"), backgroundColor: Colors.green),
            );
            // Navigate back after a short delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            });
          }
          if (state.status == EditSummaryStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? "An unknown error occurred."), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<EditSummaryBloc>();
          final theme = Theme.of(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text("Edit Visit Summary"),
              centerTitle: false,
              actions: [
                // Save Button with loading state
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilledButton.icon(
                    icon: state.status == EditSummaryStatus.saving
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(CupertinoIcons.check_mark_circled, size: 18),
                    label: Text(state.status == EditSummaryStatus.saving ? "Saving..." : "Save"),
                    onPressed: state.status == EditSummaryStatus.saving
                        ? null // Disable button while saving
                        : () => bloc.add(SaveSummaryButtonPressed()),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Doctor's Notes
                  const SectionTitle("Doctor's Notes"),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: state.doctorNotes,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: "Enter your summary for this visit...\n(e.g., symptoms, diagnosis, treatment plan)",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    onChanged: (value) => bloc.add(NotesChanged(value)),
                  ),
                  const SizedBox(height: 24),

                  // Section 2: Prescription
                  const SectionTitle("Prescription"),
                  const SizedBox(height: 12),
                  PrescriptionList(
                    items: state.prescription, // Data from BLoC state
                    onAddItem: () => _showAddPrescriptionDialog(context, bloc),
                    onDeleteItem: (item) => bloc.add(PrescriptionItemRemoved(item)),
                  ),
                  const SizedBox(height: 24),

                  // Section 3: Attached Files
                  const SectionTitle("Attached Files"),
                  const SizedBox(height: 12),
                  AttachedFilesList(
                    existingFiles: state.existingFiles,
                    newlyPickedFiles: state.newlyPickedFiles,
                    onAddFile: () => _pickFiles(context, bloc),
                    onDeleteNewlyPickedFile: (file) => bloc.add(NewlyPickedFileRemoved(file)),
                    onDeleteExistingFile: (fileEntity) => bloc.add(ExistingFileRemoved(fileEntity)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Helper methods are now static or outside the build method ---

  Future<void> _pickFiles(BuildContext context, EditSummaryBloc bloc) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
      );
      if (result != null) {
        // Convert PlatformFile to File
        final files = result.paths.map((path) => File(path!)).toList();
        bloc.add(FilesPicked(files));
      }
    } catch (e) {
      print("Error picking files: $e");
    }
  }

  void _showAddPrescriptionDialog(BuildContext context, EditSummaryBloc bloc) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final medicineController = TextEditingController();
        final dosageController = TextEditingController();
        return AlertDialog(
          title: const Text("Add Medicine"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: medicineController, decoration: const InputDecoration(labelText: "Medicine Name")),
              TextField(controller: dosageController, decoration: const InputDecoration(labelText: "Dosage")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
            FilledButton(
              onPressed: () {
                if (medicineController.text.isNotEmpty && dosageController.text.isNotEmpty) {
                  final newItem = PrescriptionItemEntity(
                    medicine: medicineController.text,
                    dosage: dosageController.text,
                  );
                  bloc.add(PrescriptionItemAdded(newItem));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}