part of 'edit_summary_bloc.dart'; // BLoC file se jodne ke liye

abstract class EditSummaryEvent extends Equatable {
  const EditSummaryEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the screen is first loaded to initialize the state
/// with the existing appointment data.
class InitializeSummary extends EditSummaryEvent {
  final AppointmentEntity appointment;

  const InitializeSummary(this.appointment);

  @override
  List<Object> get props => [appointment];
}

/// Dispatched whenever the text in the notes field changes.
class NotesChanged extends EditSummaryEvent {
  final String notes;

  const NotesChanged(this.notes);

  @override
  List<Object> get props => [notes];
}

/// Dispatched when a new prescription item is successfully added via the dialog.
class PrescriptionItemAdded extends EditSummaryEvent {
  final PrescriptionItemEntity item;

  const PrescriptionItemAdded(this.item);

  @override
  List<Object> get props => [item];
}

/// Dispatched when the delete button on a prescription item is tapped.
class PrescriptionItemRemoved extends EditSummaryEvent {
  final PrescriptionItemEntity item;

  const PrescriptionItemRemoved(this.item);

  @override
  List<Object> get props => [item];
}

/// Dispatched when the user successfully picks one or more files.
class FilesPicked extends EditSummaryEvent {
  final List<File> files;

  const FilesPicked(this.files);

  @override
  List<Object> get props => [files];
}

/// Dispatched when the delete button on a newly picked file is tapped.
class NewlyPickedFileRemoved extends EditSummaryEvent {
  final File file;

  const NewlyPickedFileRemoved(this.file);

  @override
  List<Object> get props => [file];
}

/// Dispatched when the delete button on an already existing (uploaded) file is tapped.
class ExistingFileRemoved extends EditSummaryEvent {
  final AttachedFileEntity file;

  const ExistingFileRemoved(this.file);

  @override
  List<Object> get props => [file];
}


/// Dispatched when the user taps the final "Save" button in the AppBar.
class SaveSummaryButtonPressed extends EditSummaryEvent {}