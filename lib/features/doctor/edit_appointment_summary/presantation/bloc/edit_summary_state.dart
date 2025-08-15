part of 'edit_summary_bloc.dart'; // BLoC file se jodne ke liye

enum EditSummaryStatus {
  initial,    // Before anything has happened
  loading,    // When initializing/loading initial data
  loaded,     // When form is ready and idle for user input
  saving,     // When the "Save" button is pressed and data is being processed
  success,    // When data has been successfully saved
  failure     // When any operation fails
}

class EditSummaryState extends Equatable {
  /// The current status of the screen (e.g., loading, saving, success).
  final EditSummaryStatus status;

  /// The current text content of the doctor's notes field.
  final String doctorNotes;

  /// The current list of prescribed medicines.
  final List<PrescriptionItemEntity> prescription;

  /// The list of new local files picked by the user that need to be uploaded.
  final List<File> newlyPickedFiles;
  
  /// The list of files that were already attached to the appointment from a previous session.
  final List<AttachedFileEntity> existingFiles;

  /// Holds an error message if the status is `failure`.
  final String? errorMessage;

  const EditSummaryState({
    this.status = EditSummaryStatus.initial,
    this.doctorNotes = '',
    this.prescription = const [],
    this.newlyPickedFiles = const [],
    this.existingFiles = const [],
    this.errorMessage,
  });

  /// Creates a copy of the current state with updated values.
  /// This is essential for emitting new states in the BLoC.
  EditSummaryState copyWith({
    EditSummaryStatus? status,
    String? doctorNotes,
    List<PrescriptionItemEntity>? prescription,
    List<File>? newlyPickedFiles,
    List<AttachedFileEntity>? existingFiles,
    String? errorMessage,
    bool clearErrorMessage = false, // A flag to explicitly set the error message to null
  }) {
    return EditSummaryState(
      status: status ?? this.status,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      prescription: prescription ?? this.prescription,
      newlyPickedFiles: newlyPickedFiles ?? this.newlyPickedFiles,
      existingFiles: existingFiles ?? this.existingFiles,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        doctorNotes,
        prescription,
        newlyPickedFiles,
        existingFiles,
        errorMessage,
      ];
}