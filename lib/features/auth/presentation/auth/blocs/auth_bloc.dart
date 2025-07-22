import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:health_connect/core/error/failures.dart' as auth;
import 'package:health_connect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/register_usecase.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUseCase;
  final RegisterUsecase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  AuthBloc(this.loginUseCase, this.registerUseCase, this.logoutUseCase, this.getCurrentUserUseCase) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final Either<auth.AuthFailure, UserEntity> result = await loginUseCase(
          email: event.email,
          password: event.password,
        );
        result.fold(
          (auth.AuthFailure failure) {
            emit(AuthFailure(message: failure.message));
          },
          (UserEntity user) {
            print("User logged in: ${user.id}");
            emit(Authenticated(user));
          },
        );
      } catch (e) {
        print("Login failed: $e");
        emit(AuthFailure(message: e.toString()));
      }
    });
    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final Either<auth.AuthFailure, UserEntity> result =
            await registerUseCase(
              name: event.name,
              email: event.email,
              password: event.password,
              selectedRole: event.selectedRole,
            );
        result.fold(
          (f) {
            emit(AuthFailure(message: f.message));
          },
          (user) {
            print("User registered: ${user.id}");
            emit(Authenticated(user));
          },
        );
      } catch (e) {
        print("Registration failed: $e");
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<AuthCheckRequested>((event, emit) async {
      final currentUser = await getCurrentUserUseCase.getCurrentUser();
      if (currentUser != null) {
        emit(Authenticated(currentUser));
      } else {
        emit(Unauthenticated());
      }
    });
     on<LogoutRequested>((event, emit) async {
    emit(AuthLoading());
    try {
      await logoutUseCase();
      emit(Unauthenticated());
    } catch (e) {
      print("Logout failed: $e");
      emit(AuthFailure(message: e.toString()));
    }
  });
  }

}
