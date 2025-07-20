import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_connect/core/themes/theme_manager.dart';

import 'package:health_connect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:health_connect/features/auth/domain/repositories/auth_repository.dart';
import 'package:health_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Firebase
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // UseCase
  sl.registerLazySingleton<LoginUsecase>(() => LoginUsecase(sl()));
  sl.registerLazySingleton<RegisterUsecase>(() => RegisterUsecase(sl()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));
  sl.registerLazySingleton<GetCurrentUserUseCase>(()=> GetCurrentUserUseCase(sl()));

  // Bloc
  sl.registerFactory(() => AuthBloc(sl(), sl<RegisterUsecase>(), sl<LogoutUseCase>(), sl<GetCurrentUserUseCase>()));

  // Theme Cubit
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

}
