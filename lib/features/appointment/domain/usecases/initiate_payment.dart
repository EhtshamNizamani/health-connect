import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:health_connect/features/appointment/domain/repositories/appointment_repository.dart';

class InitiatePaymentUseCase implements UseCase<String, InitiatePaymentParams> {
  final AppointmentRepository repository;

  InitiatePaymentUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(InitiatePaymentParams params) async {
    return await repository.initiatePayment(
      doctorId: params.doctorId,
      amount: params.amount,
    );
  }
}

class InitiatePaymentParams {
  final String doctorId;
  final int amount;

  InitiatePaymentParams({required this.doctorId, required this.amount});
}