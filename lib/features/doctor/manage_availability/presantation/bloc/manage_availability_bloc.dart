

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/data/entities/daily_availability_entity.dart';
import 'package:health_connect/core/data/entities/time_slot_entity.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/usecase/get_current_doctor_profile_usecase.dart';
import 'package:health_connect/features/doctor/manage_availability/domain/usecase/save_doctor_availability_usecase.dart';
// Import your use cases

import 'manage_availability_event.dart';
import 'manage_availability_state.dart';

class ManageAvailabilityBloc
    extends Bloc<ManageAvailabilityEvent, ManageAvailabilityState> {
  final GetCurrentDoctorProfileUseCase _getDoctorProfileUseCase;
  final SaveDoctorAvailabilityUseCase _saveAvailabilityUseCase;

  ManageAvailabilityBloc(
    this._getDoctorProfileUseCase,
    this._saveAvailabilityUseCase,
  ) : super(ManageAvailabilityInitial()) {
    // Register all event handlers
    on<LoadInitialSchedule>(_onLoadInitialSchedule);
    on<DayToggled>(_onDayToggled);
    on<TimeSlotAdded>(_onTimeSlotAdded);
    on<TimeSlotRemoved>(_onTimeSlotRemoved);
    on<ScheduleSaved>(_onScheduleSaved);
  }

  // --- Event Handlers ---

  Future<void> _onLoadInitialSchedule(
    LoadInitialSchedule event,
    Emitter<ManageAvailabilityState> emit,
  ) async {
    emit(ManageAvailabilityLoading());
    final result = await _getDoctorProfileUseCase();
    result.fold(
      (failure) => emit(ManageAvailabilityError({}, failure.message)),
      (doctor) {
        if (doctor.weeklyAvailability.isEmpty) {
          // If it's empty, create a default "all days off" schedule
          final defaultSchedule = {
            'monday': const DailyAvailability(isWorking: false, slots: []),
            'tuesday': const DailyAvailability(isWorking: false, slots: []),
            'wednesday': const DailyAvailability(isWorking: false, slots: []),
            'thursday': const DailyAvailability(isWorking: false, slots: []),
            'friday': const DailyAvailability(isWorking: false, slots: []),
            'saturday': const DailyAvailability(isWorking: false, slots: []),
            'sunday': const DailyAvailability(isWorking: false, slots: []),
          };
          emit(ManageAvailabilityLoaded(defaultSchedule));
        } else {
          // If a schedule already exists, show that one
          emit(ManageAvailabilityLoaded(doctor.weeklyAvailability));
        }
      }
    );
  }

  void _onDayToggled(
    DayToggled event,
    Emitter<ManageAvailabilityState> emit,
  ) {
    final newSchedule = Map<String, DailyAvailability>.from(state.schedule);
    final daySchedule = newSchedule[event.day]!;
    newSchedule[event.day] = DailyAvailability(
      isWorking: event.isWorking,
      slots: event.isWorking ? daySchedule.slots : [], // Clear slots if day is off
    );
    emit(ManageAvailabilityLoaded(newSchedule));
  }
  
  void _onTimeSlotAdded(
    TimeSlotAdded event,
    Emitter<ManageAvailabilityState> emit,
  ) {
    final newSchedule = Map<String, DailyAvailability>.from(state.schedule);
    final daySchedule = newSchedule[event.day]!;
    final updatedSlots = List<TimeSlot>.from(daySchedule.slots)..add(event.newSlot);
    
    newSchedule[event.day] = DailyAvailability(
      isWorking: daySchedule.isWorking,
      slots: updatedSlots,
    );
    emit(ManageAvailabilityLoaded(newSchedule));
  }

  void _onTimeSlotRemoved(
    TimeSlotRemoved event,
    Emitter<ManageAvailabilityState> emit,
  ) {
    final newSchedule = Map<String, DailyAvailability>.from(state.schedule);
    final daySchedule = newSchedule[event.day]!;
    final updatedSlots = List<TimeSlot>.from(daySchedule.slots)..remove(event.slotToRemove);

    newSchedule[event.day] = DailyAvailability(
      isWorking: daySchedule.isWorking,
      slots: updatedSlots,
    );
    emit(ManageAvailabilityLoaded(newSchedule));
  }
  
  Future<void> _onScheduleSaved(
    ScheduleSaved event,
    Emitter<ManageAvailabilityState> emit,
  ) async {
    // Emit saving state but keep the current schedule for the UI
    emit(ManageAvailabilitySaving(state.schedule)); 
    final result = await _saveAvailabilityUseCase(state.schedule);
    result.fold(
      (failure) => emit(ManageAvailabilityError(state.schedule, failure.message)),
      (_) => emit(ManageAvailabilitySaveSuccess(state.schedule)),
    );
  }

  @override
  void onTransition(Transition<ManageAvailabilityEvent, ManageAvailabilityState> transition) {
    super.onTransition(transition);
    print("ManageAvailabilityBloc Transition: $transition");
  }
}