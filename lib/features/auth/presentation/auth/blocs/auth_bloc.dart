import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/is_doctor_profile_exists_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/register_usecase.dart';

import 'auth_event.dart';
import 'auth_state.dart';
// auth_bloc.dart

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // --- YE AAPKE PAAS PEHLE SE HONA CHAHIYE ---
  final LoginUsecase loginUseCase;
  final RegisterUsecase registerUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final IsDoctorProfileExistsUseCase isDoctorProfileExistsUseCase;

  AuthBloc(
     this.loginUseCase,
     this.registerUseCase,
     this.getCurrentUserUseCase,
     this.logoutUseCase,
     this.isDoctorProfileExistsUseCase, 
  ) : super(AuthInitial()) {

    Future<void> handleAuthentication(
        UserEntity user, Emitter<AuthState> emit) async {

      if (user.role == 'patient') {

        emit(AuthenticatedPatient(user));
      } else if (user.role == 'doctor') {

        final profileResult = await isDoctorProfileExistsUseCase(user.id);

        profileResult.fold(
          (failure) {
      print("test ${failure.message}");

emit(AuthFailure(message: failure.message));
          } ,
          (exists) {

            if (exists) {
              emit(AuthenticatedDoctorProfileExists(user));
            } else {
              emit(AuthenticatedDoctorProfileNotExists(user));
            }
          },
        );
      } else {
        emit( AuthFailure(message: "Unknown user role."));
      }
    }
on<LoginRequested>((event, emit) async {
  emit(AuthLoading());
  final result = await loginUseCase(
    email: event.email,
    password: event.password,
  );
 await result.fold((l)async => emit(AuthFailure(message: l.message)), (user) async {
    // Agar login successful hai, to user ko handle karo
    await handleAuthentication(user, emit);
  });

});

    // --- LOGIC #2: Jab naya user register kare ---
    // Ye simple logic hai, ismein profile check nahi hoga.
   on<RegisterRequested>((event, emit) async {
  emit(AuthLoading());
  final result = await registerUseCase(
        name: event.name,
        email: event.email,
        password: event.password,
        selectedRole: event.selectedRole,
      );  await result.fold(
    (failure) async => emit(AuthFailure(message: failure.message)),
    (user) async {
      if (user.role == 'patient') {
        emit(AuthenticatedPatient(user));
      } else if (user.role == 'doctor') {
        emit(AuthenticatedDoctorProfileNotExists(user));
      } else {
        emit(AuthFailure(message: "Unknown role..."));
      }
    },
  );
});
   on<AuthCheckRequested>((event, emit) async {

      try {
        // Step 1: Current user ko fetch karne ki koshish karo
        final currentUser = await getCurrentUserUseCase();

        // Step 2: Check karo ki user mila ya nahi
        if (currentUser != null) {

          // Agar user mila, to a-ch-chhe se profile check karo
          await handleAuthentication(currentUser, emit);
        } else {
          // Agar koi user nahi mila, to Unauthenticated state emit karo
          emit(Unauthenticated());
        }
      } catch (e) {
        // Step 3: AGAR KOI BHI ERROR AAYE (jaise aadha-adhura user),
        // to use pakdo aur Unauthenticated state emit kardo.
        // Ye hamara "safety net" hai.
        print("AuthCheck failed with error: $e. Forcing Unauthenticated state.");
        emit(Unauthenticated());
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      await logoutUseCase();
      emit(Unauthenticated());
    });
  }

  //   @override
  // void onTransition(Transition<AuthEvent, AuthState> transition) {
  //   super.onTransition(transition);
  //   print("AuthBloc Transition: $transition");
  // }
}