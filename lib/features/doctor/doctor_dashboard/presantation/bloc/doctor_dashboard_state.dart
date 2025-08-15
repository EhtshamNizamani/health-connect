part of 'doctor_dashboard_bloc.dart';

sealed class DoctorDashboardState extends Equatable {
  const DoctorDashboardState();
  
  @override
  List<Object> get props => [];
}

/// The initial state before any action is taken.
class DoctorDashboardInitial extends DoctorDashboardState {}

/// The state when data is being fetched for the first time.
/// The UI will show a skeleton loader in this state.
class DoctorDashboardLoading extends DoctorDashboardState {}

/// The state when an error occurs while fetching or processing data.
class DoctorDashboardError extends DoctorDashboardState {
  final String message;
  const DoctorDashboardError(this.message);

  @override
  List<Object> get props => [message];
}

/// The state when dashboard data has been successfully loaded.
/// It contains the [DoctorDashboardEntity] which the UI will use to render.
class DoctorDashboardLoaded extends DoctorDashboardState {
  final DoctorDashboardEntity dashboardData;

  const DoctorDashboardLoaded(this.dashboardData);

  @override
  List<Object> get props => [dashboardData];
}