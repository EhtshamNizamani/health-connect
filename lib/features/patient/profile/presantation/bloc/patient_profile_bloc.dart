import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_event.dart';
import 'package:health_connect/features/patient/profile/domain/uscecases/update_patient_profile_usecase.dart';

import 'patient_profile_event.dart';
import 'patient_profile_state.dart';

class PatientProfileBloc extends Bloc<PatientProfileEvent, PatientProfileState> {
  final UpdatePatientProfileUseCase _updateUseCase;
  final AuthBloc _authBloc;

  PatientProfileBloc(this._updateUseCase, this._authBloc)
      : super(PatientProfileInitial()) {
    on<UpdateProfileButtonPressed>(_onUpdateProfileButtonPressed);
    
  }

  Future<void> _onUpdateProfileButtonPressed(
    UpdateProfileButtonPressed event,
    Emitter<PatientProfileState> emit,
  ) async {
    final user = _authBloc.state.user;
    if (user == null) {
      emit(const PatientProfileFailure("User not authenticated."));
      return;
    }

    emit(PatientProfileSaving());

     final updatedUser = UserEntity(
      id: user.id,
      name: event.name,
      email: user.email,
      role: user.role,
      photoUrl: user.photoUrl, // We'll handle the new photo URL after upload
      allergies: event.allergies,
      chronicConditions: event.chronicConditions,
      age: event.age,
      gender: event.gender,
    );

    final result = await _updateUseCase(
      UpdatePatientProfileParams(
        uid: user.id,
        name: event.name,
        photoFile: event.photoFile,
        // Pass all fields to the use case
        allergies: event.allergies,
        chronicConditions: event.chronicConditions,
        age: event.age,
        gender: event.gender,
      ),
    );
    result.fold(
      (failure) => emit(PatientProfileFailure(failure.message)),
     (newPhotoUrl) {
        // --- THE FIX ---
        // Instead of AuthCheckRequested, dispatch the new event with the
        // precise, updated user data.
        
        // Create the final user entity, including the new photo URL if it exists.
        final finalUpdatedUser = updatedUser.copyWith(
          photoUrl: newPhotoUrl ?? user.photoUrl,
        );

        _authBloc.add(AuthUserUpdated(finalUpdatedUser));
        emit(PatientProfileSuccess());
      },
    );
  }
}