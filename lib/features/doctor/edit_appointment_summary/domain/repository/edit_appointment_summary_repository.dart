import 'dart:io' show File;

import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/domain/entities/attached_file_entity.dart';

abstract class EditAppointmentSummaryRepository {
  /// Uploads a list of local files to a dedicated folder for the appointment.
  /// Returns a list of public download URLs upon success.
  Future<Either<Failure, List<AttachedFileEntity>>> uploadFiles(
    List<File> files,
    String appointmentId,
  );

  /// Updates the appointment document in Firestore with the new summary.
  Future<Either<Failure, void>> updateAppointmentSummary(
    AppointmentEntity updatedAppointment,
  );
  
  /// (Optional but Recommended) Deletes a specific file from Firebase Storage.
  Future<Either<Failure, void>> deleteFile(AttachedFileEntity file);
}