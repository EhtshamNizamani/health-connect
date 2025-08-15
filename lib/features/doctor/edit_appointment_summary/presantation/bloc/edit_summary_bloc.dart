import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/domain/entities/attached_file_entity.dart';
import 'package:health_connect/features/appointment/domain/entities/prescription_item_entity.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/domain/usecase/edit_appointment_summary.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/domain/usecase/upload_files_usecase.dart';
part 'edit_summary_event.dart';
part 'edit_summary_state.dart';


class EditSummaryBloc extends Bloc<EditSummaryEvent, EditSummaryState> {
  final UpdateAppointmentSummaryUseCase _updateSummaryUseCase;
  final UploadFilesUseCase _uploadFilesUseCase;
  
  // Store the original appointment to get IDs and other static data
  AppointmentEntity? _originalAppointment;

  EditSummaryBloc({
    required UpdateAppointmentSummaryUseCase updateSummaryUseCase,
    required UploadFilesUseCase uploadFilesUseCase,
  })  : _updateSummaryUseCase = updateSummaryUseCase,
        _uploadFilesUseCase = uploadFilesUseCase,
        super(const EditSummaryState()) {
          
    on<InitializeSummary>(_onInitializeSummary);
    on<NotesChanged>(_onNotesChanged);
    on<PrescriptionItemAdded>(_onPrescriptionItemAdded);
    on<PrescriptionItemRemoved>(_onPrescriptionItemRemoved);
    on<FilesPicked>(_onFilesPicked);
    on<NewlyPickedFileRemoved>(_onNewlyPickedFileRemoved);
    on<ExistingFileRemoved>(_onExistingFileRemoved);
    on<SaveSummaryButtonPressed>(_onSaveSummaryButtonPressed);
  }

  void _onInitializeSummary(InitializeSummary event, Emitter<EditSummaryState> emit) {
    _originalAppointment = event.appointment;
    emit(state.copyWith(
      status: EditSummaryStatus.loaded,
      doctorNotes: event.appointment.doctorNotes,
      prescription: event.appointment.prescription,
      existingFiles: event.appointment.attachedFiles,
      newlyPickedFiles: [], // Start with an empty list of new files
    ));
  }

  void _onNotesChanged(NotesChanged event, Emitter<EditSummaryState> emit) {
    emit(state.copyWith(doctorNotes: event.notes));
  }

  void _onPrescriptionItemAdded(PrescriptionItemAdded event, Emitter<EditSummaryState> emit) {
    final updatedList = List<PrescriptionItemEntity>.from(state.prescription)..add(event.item);
    emit(state.copyWith(prescription: updatedList));
  }

  void _onPrescriptionItemRemoved(PrescriptionItemRemoved event, Emitter<EditSummaryState> emit) {
    final updatedList = List<PrescriptionItemEntity>.from(state.prescription)..remove(event.item);
    emit(state.copyWith(prescription: updatedList));
  }

  void _onFilesPicked(FilesPicked event, Emitter<EditSummaryState> emit) {
    final updatedList = List<File>.from(state.newlyPickedFiles)..addAll(event.files);
    emit(state.copyWith(newlyPickedFiles: updatedList));
  }
  
  void _onNewlyPickedFileRemoved(NewlyPickedFileRemoved event, Emitter<EditSummaryState> emit) {
    final updatedList = List<File>.from(state.newlyPickedFiles)..remove(event.file);
    emit(state.copyWith(newlyPickedFiles: updatedList));
  }
  
  void _onExistingFileRemoved(ExistingFileRemoved event, Emitter<EditSummaryState> emit) {
    // This is more complex. Deleting an existing file requires a call to Firebase Storage.
    // For now, we'll just remove it from the UI. A "Save" action would then update the final list in Firestore.
    final updatedList = List<AttachedFileEntity>.from(state.existingFiles)..remove(event.file);
    emit(state.copyWith(existingFiles: updatedList));
  }

  Future<void> _onSaveSummaryButtonPressed(
    SaveSummaryButtonPressed event,
    Emitter<EditSummaryState> emit,
  ) async {
    if (_originalAppointment == null) {
      emit(state.copyWith(status: EditSummaryStatus.failure, errorMessage: "Original appointment data not found."));
      return;
    }

    emit(state.copyWith(status: EditSummaryStatus.saving));
    
    // --- Step 1: Upload new files and get their URLs ---
    final uploadResult = await _uploadFilesUseCase(UploadFilesParams(files: state.newlyPickedFiles, appointmentId: _originalAppointment!.id));

    await uploadResult.fold(
      (failure) {
        // If upload fails, emit failure state and stop
        emit(state.copyWith(status: EditSummaryStatus.failure, errorMessage: failure.message));
      },
      (newFileUrls) async {
        // --- Step 2: Create the list of final attached files ---
        // Combine existing files with newly uploaded ones
        final List<AttachedFileEntity> finalAttachedFiles = [
          ...state.existingFiles,
          // Create AttachedFileEntity objects from the new URLs
          ...newFileUrls.asMap().entries.map((entry) {
            final index = entry.key;
            final url = entry.value;
            return AttachedFileEntity(
              fileName: state.newlyPickedFiles[index].path.split('/').last,
              url: url.toString(),
            );
          }),
        ];
        
        // --- Step 3: Create the updated AppointmentEntity ---
        // We use the original appointment to create a new instance with updated fields
        final updatedAppointment = AppointmentEntity(
          id: _originalAppointment!.id,
          doctorId: _originalAppointment!.doctorId,
          patientId: _originalAppointment!.patientId,
          doctorName: _originalAppointment!.doctorName,
          patientName: _originalAppointment!.patientName,
          doctorPhotoUrl: _originalAppointment!.doctorPhotoUrl,
          patientPhotoUrl: _originalAppointment!.patientPhotoUrl,
          appointmentDateTime: _originalAppointment!.appointmentDateTime,
          status: _originalAppointment!.status,
          consultationFee: _originalAppointment!.consultationFee,
          createdAt: _originalAppointment!.createdAt,
          isReviewed: _originalAppointment!.isReviewed,
          isReadByDoctor: _originalAppointment!.isReadByDoctor,
          isReadByPatient: _originalAppointment!.isReadByPatient,
          // --- Updated fields from the current state ---
          doctorNotes: state.doctorNotes,
          prescription: state.prescription,
          attachedFiles: finalAttachedFiles,
        );

        // --- Step 4: Call the use case to save the data to Firestore ---
        final saveResult = await _updateSummaryUseCase(updatedAppointment);

        saveResult.fold(
          (failure) {
            emit(state.copyWith(status: EditSummaryStatus.failure, errorMessage: failure.message));
          },
          (_) {
            // --- Step 5: Emit Success state ---
            emit(state.copyWith(status: EditSummaryStatus.success));
          },
        );
      },
    );
  }
}