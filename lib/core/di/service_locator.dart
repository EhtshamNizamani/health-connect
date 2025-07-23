import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_connect/core/themes/theme_manager.dart';

import 'package:health_connect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:health_connect/features/auth/domain/repositories/auth_repository.dart';
import 'package:health_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/is_doctor_profile_exists_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/data/repositories/doctor_repository_impl.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/repositories/doctor_repository.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/usecase/save_doctor_usecase.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/bloc/doctor_profile_setup_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Firebase
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(),sl()));
  sl.registerLazySingleton<DoctorRepository>(()=> DoctorRepositoryImpl(sl(), sl(), sl()));
  // UseCase
  sl.registerLazySingleton<LoginUsecase>(() => LoginUsecase(sl()));
  sl.registerLazySingleton<RegisterUsecase>(() => RegisterUsecase(sl()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));
  sl.registerLazySingleton<GetCurrentUserUseCase>(()=> GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton<SaveDoctorProfileUseCase>(() => SaveDoctorProfileUseCase(sl()));
  sl.registerLazySingleton<IsDoctorProfileExistsUseCase>(() => IsDoctorProfileExistsUseCase(sl())); 
  // Bloc
  sl.registerFactory(() => AuthBloc(sl<LoginUsecase>(), sl<RegisterUsecase>(), sl<GetCurrentUserUseCase>(), sl<LogoutUseCase>(), sl<IsDoctorProfileExistsUseCase>()));
  sl.registerFactory(() => DoctorProfileSetupBloc(sl()));
  // Theme Cubit
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

}
