import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/features/appointment/data/models/appointment_model.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/appointment/domain/entities/attached_file_entity.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/domain/repository/edit_appointment_summary_repository.dart';

class EditAppointmentSummaryRepositoryImpl implements EditAppointmentSummaryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  EditAppointmentSummaryRepositoryImpl(this._firestore, this._storage);

  @override
  Future<Either<Failure, List<AttachedFileEntity>>> uploadFiles(
    List<File> files,
    String appointmentId,
  ) async {
    try {
      if (files.isEmpty) {
        return const Right([]); // No files to upload, return success with empty list
      }

      final List<AttachedFileEntity> uploadedFiles = [];
      
      // Upload each file one by one
      for (final file in files) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        final ref = _storage.ref().child('appointment_attachments/$appointmentId/$fileName');
        
        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();
        
        uploadedFiles.add(AttachedFileEntity(fileName: fileName, url: downloadUrl));
      }
      
      return Right(uploadedFiles);
    } on FirebaseException catch (e) {
      return Left(StorageFailure("Failed to upload files: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unexpected error occurred during file upload: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> updateAppointmentSummary(
    AppointmentEntity updatedAppointment,
  ) async {
    try {
      // Convert the updated entity to a model, then to a map
      final appointmentModel = AppointmentModel.fromEntity(updatedAppointment);
      final dataToUpdate = appointmentModel.toMap();

      // We only need to update the fields that can be edited in this screen
      final finalUpdateData = {
        'doctorNotes': dataToUpdate['doctorNotes'],
        'prescription': dataToUpdate['prescription'],
        'attachedFiles': dataToUpdate['attachedFiles'],
      };

      await _firestore
          .collection('appointments')
          .doc(updatedAppointment.id)
          .update(finalUpdateData);
          
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure("Failed to save summary: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unexpected error occurred while saving: $e"));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteFile(AttachedFileEntity file) async {
    try {
      // Get a reference to the file from its download URL
      final ref = _storage.refFromURL(file.url);
      await ref.delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(StorageFailure("Failed to delete file: ${e.message}"));
    } catch (e) {
      return Left(ServerFailure("An unexpected error occurred while deleting file: $e"));
    }
  }
}