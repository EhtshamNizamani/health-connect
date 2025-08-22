
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_event.dart';
import 'package:health_connect/features/patient/medical_info/domain/usecases/update_patient_medical_info_usecase.dart';
import 'package:health_connect/features/patient/medical_info/presentation/bloc/update_medical_info_bloc_event.dart';
import 'package:health_connect/features/patient/medical_info/presentation/bloc/update_medical_info_bloc_state.dart';

class UpdateMedicalInfoBloc extends Bloc<UpdateMedicalInfoEvent, UpdateMedicalInfoState> {
  final UpdatePatientMedicalInfoUseCase _updateUseCase;
  final AuthBloc _authBloc; // To get the current user

  UpdateMedicalInfoBloc(this._updateUseCase, this._authBloc)
      : super(UpdateMedicalInfoInitial()) {
    on<UpdateInfoButtonPressed>(_onUpdateInfoButtonPressed);
  }

  Future<void> _onUpdateInfoButtonPressed(
    UpdateInfoButtonPressed event,
    Emitter<UpdateMedicalInfoState> emit,
  ) async {
    emit(UpdateMedicalInfoSaving());

    final currentUser = _authBloc.state.user;
    if (currentUser == null) {
      emit(const UpdateMedicalInfoFailure("User not found. Please log in again."));
      return;
    }

    // Create a new UserEntity with the updated data, preserving the old data
    final updatedUser = UserEntity(
      id: currentUser.id,
      name: currentUser.name,
      email: currentUser.email,
      role: currentUser.role,
      photoUrl: currentUser.photoUrl,
      // Use the new data from the event
      allergies: event.allergies,
      chronicConditions: event.chronicConditions,
      age: event.age,
      gender: event.gender,
    );

    final result = await _updateUseCase(updatedUser);

    result.fold(
      (failure) => emit(UpdateMedicalInfoFailure(failure.message)),
      (_) {
        _authBloc.add(AuthCheckRequested());
        emit(UpdateMedicalInfoSuccess());
      },
    );
  }
}