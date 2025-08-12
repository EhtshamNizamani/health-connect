part of 'doctor_dashboard_bloc.dart';

sealed class DoctorDashboardEvent extends Equatable {
  const DoctorDashboardEvent();

  @override
  List<Object> get props => [];
}


class FetchDashboardData extends DoctorDashboardEvent {}