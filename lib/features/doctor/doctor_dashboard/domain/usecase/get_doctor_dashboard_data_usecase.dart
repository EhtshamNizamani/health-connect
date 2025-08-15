import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';
import 'package:health_connect/core/usecases/usecase.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/domain/entities/doctor_dashboard_entity.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/domain/repository/doctor_dashboard_repository.dart';

// <<< --- YAHAN TYPE KO THEEK KIYA GAYA HAI ---
// Type ab Stream hai, to UseCase `Future<Either<Failure, Stream<...>>>` expect karega
class GetDoctorDashboardDataUseCase implements UseCase<Stream<Either<Failure, DoctorDashboardEntity>>, String> {
  final DoctorDashboardRepository repository;

  GetDoctorDashboardDataUseCase(this.repository);

  // <<< --- METHOD SIGNATURE AB VALID HAI ---
  @override
  Future<Either<Failure, Stream<Either<Failure, DoctorDashboardEntity>>>> call(String doctorId) async {
    // 1. Get the raw stream of appointments from the repository
    final appointmentsStreamResult = repository.getDoctorAppointmentsStream(doctorId);

    // 2. Repository se aane wala result already ek stream hai,
    // to hum use bas ek successful Future ke andar wrap kar denge.
    // Hum `Either` ka istemaal karke `right` side par stream bhej rahe hain.
    return Right(
      // 3. Ab is stream ko transform karein
      appointmentsStreamResult.map((eitherResult) {
        // Use .map from dartz to only process the success case (Right)
        return eitherResult.map((allAppointments) {
          // --- SAARA BUSINESS LOGIC YAHAN HAI ---
          final now = DateTime.now();
          final startOfToday = DateTime(now.year, now.month, now.day);
          final endOfToday = startOfToday.add(const Duration(days: 1));

          final todaysAppointments = allAppointments.where((appt) {
            return appt.appointmentDateTime.isAfter(startOfToday) &&
                   appt.appointmentDateTime.isBefore(endOfToday) &&
                   appt.status != 'cancelled' &&
                   appt.status != 'no-show';
          }).toList();
          final todaysAppointmentsCount = todaysAppointments.length;

          final totalPendingRequestsCount = allAppointments
              .where((appt) => appt.status == 'pending')
              .length;

          final upcomingToday = todaysAppointments
              .where((appt) => appt.status == 'confirmed' && appt.appointmentDateTime.isAfter(now))
              .toList();
          upcomingToday.sort((a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime));
          final AppointmentEntity? nextAppointment = upcomingToday.isNotEmpty ? upcomingToday.first : null;

          todaysAppointments.sort((a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime));
          final todaysAgenda = todaysAppointments.take(4).toList();

          return DoctorDashboardEntity(
            todaysAppointmentsCount: todaysAppointmentsCount,
            totalPendingRequestsCount: totalPendingRequestsCount,
            nextAppointment: nextAppointment,
            todaysAgenda: todaysAgenda,
          );
        });
      }),
    );
  }
}