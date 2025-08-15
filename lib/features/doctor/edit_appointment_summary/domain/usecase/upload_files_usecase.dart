import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:health_connect/features/appointment/domain/entities/attached_file_entity.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/domain/repository/edit_appointment_summary_repository.dart';


class UploadFilesUseCase implements UseCase<List<AttachedFileEntity>, UploadFilesParams> {
  final EditAppointmentSummaryRepository repository;

  UploadFilesUseCase(this.repository);

  @override
  Future<Either<Failure, List<AttachedFileEntity>>> call(UploadFilesParams params) async {
    return await repository.uploadFiles(params.files, params.appointmentId);
  }
}

class UploadFilesParams {
  final List<File> files;
  final String appointmentId;
  UploadFilesParams({required this.files, required this.appointmentId});
}