import 'package:equatable/equatable.dart';
import 'package:health_connect/features/doctor/appointment_detail/domain/entity/appointment_detail_entity.dart';

abstract class AppointmentDetailState extends Equatable {
  const AppointmentDetailState();
  @override
  List<Object?> get props => [];
}

class AppointmentDetailInitial extends AppointmentDetailState {}
class AppointmentDetailLoading extends AppointmentDetailState {}
class AppointmentDetailError extends AppointmentDetailState {
  final String message;
  const AppointmentDetailError(this.message);
  @override
  List<Object> get props => [message];
}
class AppointmentDetailLoaded extends AppointmentDetailState {
  final AppointmentDetailEntity details;
  const AppointmentDetailLoaded(this.details);
  @override
  List<Object> get props => [details];
}