

import 'package:equatable/equatable.dart';
import 'package:health_connect/core/data/entities/daily_availability_entity.dart';

abstract class ManageAvailabilityState extends Equatable {
  final Map<String, DailyAvailability> schedule;
  const ManageAvailabilityState(this.schedule);
  
  @override
  List<Object> get props => [schedule];
}

// Initial state, before anything is loaded
class ManageAvailabilityInitial extends ManageAvailabilityState {
  ManageAvailabilityInitial() : super({});
}

// State while loading the initial schedule
class ManageAvailabilityLoading extends ManageAvailabilityState {
  ManageAvailabilityLoading() : super({});
}

// The main state when the schedule is loaded and can be edited
class ManageAvailabilityLoaded extends ManageAvailabilityState {
  const ManageAvailabilityLoaded(super.schedule);
}

// State while the schedule is being saved
class ManageAvailabilitySaving extends ManageAvailabilityState {
  const ManageAvailabilitySaving(super.schedule); // Keep the schedule to show in UI
}

// State for any error that occurs
class ManageAvailabilityError extends ManageAvailabilityState {
  final String message;
  const ManageAvailabilityError(super.schedule, this.message); // Keep schedule to show in UI
  
  @override
  List<Object> get props => [schedule, message];
}

// State for when the save is successful
class ManageAvailabilitySaveSuccess extends ManageAvailabilityState {
  const ManageAvailabilitySaveSuccess(super.schedule);
}