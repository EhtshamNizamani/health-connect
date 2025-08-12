import 'package:equatable/equatable.dart';
import 'package:health_connect/features/appointment/domain/entities/appointment_entity.dart';

class DoctorDashboardEntity extends Equatable {
  final int todaysAppointmentsCount;
  final int totalPendingRequestsCount;
  final AppointmentEntity? nextAppointment;
  final List<AppointmentEntity> todaysAgenda;
  // Hum inhein baad mein add kar sakte hain
  // final double weeklyEarnings;
  // final double averageRating;

  const DoctorDashboardEntity({
    required this.todaysAppointmentsCount,
    required this.totalPendingRequestsCount,
    this.nextAppointment,
    required this.todaysAgenda,
  });

  @override
  List<Object?> get props => [
        todaysAppointmentsCount,
        totalPendingRequestsCount,
        nextAppointment,
        todaysAgenda,
      ];
}