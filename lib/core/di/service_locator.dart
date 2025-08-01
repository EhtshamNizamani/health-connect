import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_connect/core/config/zego_cloud_config.dart';
import 'package:health_connect/core/service/notification_service.dart';
import 'package:health_connect/core/themes/theme_manager.dart';
import 'package:health_connect/features/appointment/domain/usecases/get_doctor_appointments_usecase.dart';
import 'package:health_connect/features/appointment/domain/usecases/get_patient_appointments_usecase.dart';
import 'package:health_connect/features/appointment/domain/usecases/update_appointment_status_usecase.dart';

import 'package:health_connect/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:health_connect/features/auth/domain/repositories/auth_repository.dart';
import 'package:health_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/is_doctor_profile_exists_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:health_connect/features/auth/domain/usecases/update_user_profile_usecase.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/chat/data/repositories/firebase_chat_repository_impl.dart';
import 'package:health_connect/features/chat/domain/repositories/chat_repository.dart';
import 'package:health_connect/features/chat/domain/usecases/get_chat_rooms_usecase.dart';
import 'package:health_connect/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:health_connect/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:health_connect/features/chat/domain/usecases/upload_file_usecase.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_bloc.dart';
import 'package:health_connect/features/doctor/appointment/presantation/bloc/doctor_appointments_bloc.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/data/repositories_impl/doctor_profile_repository_impl.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/repositories/doctor_profile_repository.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/usecase/get_current_doctor_profile_usecase.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/usecase/save_doctor_usecase.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/bloc/doctor_profile_setup_bloc.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/data/repository/doctor_profile_update_repository_impl.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/domain/repository/doctor_profile_update_repository.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/domain/usecase/doctor_profile_update_usecase.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/presantation/bloc/doctor_profile_update_bloc.dart';
import 'package:health_connect/features/doctor/manage_availability/data/repository/firebase_%20manage_availability_repository_impl.dart';
import 'package:health_connect/features/doctor/manage_availability/domain/repository/manage_availability_repository.dart';
import 'package:health_connect/features/doctor/manage_availability/domain/usecase/save_doctor_availability_usecase.dart';
import 'package:health_connect/features/doctor/manage_availability/presantation/bloc/manage_availability_bloc.dart';
import 'package:health_connect/features/appointment/data/repositories/appointment_repository_impl.dart';
import 'package:health_connect/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:health_connect/features/appointment/domain/usecases/book_appointment_usecase.dart';
import 'package:health_connect/features/appointment/presentation/blocs/booking_bloc.dart';
import 'package:health_connect/features/doctor/review/data/repository/review_repository_impl.dart';
import 'package:health_connect/features/doctor/review/domain/repository/review_repository.dart';
import 'package:health_connect/features/doctor/review/domain/usecase/get_doctor_review_usecase.dart';
import 'package:health_connect/features/doctor/review/domain/usecase/submit_review_usecase.dart';
import 'package:health_connect/features/doctor/review/presantation/bloc/review_bloc.dart';
import 'package:health_connect/features/patient/appointment/presentation/bloc/patient_appointments_bloc.dart';
import 'package:health_connect/features/patient/doctor_list/data/repository_impl/doctor_repository_impl.dart';
import 'package:health_connect/features/patient/doctor_list/domain/repositories/doctor_repository.dart';
import 'package:health_connect/features/patient/doctor_list/domain/usecases/get_doctors_usecase.dart';
import 'package:health_connect/features/patient/doctor_list/presentation/bloc/doctor_list_bloc.dart';
import 'package:health_connect/features/patient/doctor_profile_view/data/repository_impl/doctor_profile_view_repository_impl.dart';
import 'package:health_connect/features/patient/doctor_profile_view/domain/repositroy/doctor_profile_view_repository.dart';
import 'package:health_connect/features/patient/doctor_profile_view/domain/usecase/get_available_slots_usecase.dart';
import 'package:health_connect/features/patient/doctor_profile_view/domain/usecase/get_doctor_by_id_usecase.dart';
import 'package:health_connect/features/patient/doctor_profile_view/presantion/bloc/doctor_profile_view_bloc.dart';
import 'package:health_connect/features/video_call/data/repository/call_engine_repository.dart.dart';
import 'package:health_connect/features/video_call/data/repository/video_call_repository_impl.dart';
import 'package:health_connect/features/video_call/domain/repository/call_engine_repository.dart';
import 'package:health_connect/features/video_call/domain/repository/video_call_repository.dart';
import 'package:health_connect/features/video_call/domain/usecase/accept_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/cancel_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/decline_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/initiate_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/manage_call_usecase.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/vide_call_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // <<<--- ADD THIS LINE AT THE TOP ---
  // Load environment variables first to ensure they are available for all dependencies.
  await dotenv.load(fileName: ".env");

  //configuration
  sl.registerLazySingleton(() => ZegoConfig());

  // Firebase
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  sl.registerLazySingleton<FirebaseFunctions>(
    () => FirebaseFunctions.instanceFor(region: "europe-west1"),
  );
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => ManageCallUseCase(sl(), sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<DoctorRepository>(
    () => FirebaseDoctorRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DoctorProfileRepository>(
    () => FirebaseDoctorProfileRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<DoctorProfileViewRepository>(
    () => DoctorProfileViewRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ManageAvailabilityRepository>(
    () => FirebaseManageAvailabilityRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ReviewRepository>(() => ReviewRepositoryImpl(sl()));
  sl.registerLazySingleton<DoctorProfileUpdateRepository>(
    () => DoctorProfileUpdateRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => FirebaseChatRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<CallEngineRepository>(
    () => CallEngineRepositoryImpl(sl<ZegoConfig>()),
  );
  sl.registerLazySingleton<VideoCallRepository>(
    () => VideoCallRepositoryImpl(sl(), sl()),
  );
  // UseCase
  sl.registerLazySingleton<LoginUsecase>(() => LoginUsecase(sl()));
  sl.registerLazySingleton<RegisterUsecase>(() => RegisterUsecase(sl()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl()),
  );
  sl.registerLazySingleton<SaveDoctorProfileUseCase>(
    () => SaveDoctorProfileUseCase(sl()),
  );
  sl.registerLazySingleton<IsDoctorProfileExistsUseCase>(
    () => IsDoctorProfileExistsUseCase(sl()),
  );
  sl.registerLazySingleton<GetDoctorByIdUseCase>(
    () => GetDoctorByIdUseCase(sl()),
  );
  sl.registerLazySingleton<GetDoctorsUseCase>(() => GetDoctorsUseCase(sl()));
  sl.registerLazySingleton<GetCurrentDoctorProfileUseCase>(
    () => GetCurrentDoctorProfileUseCase(sl()),
  );
  sl.registerLazySingleton<SaveDoctorAvailabilityUseCase>(
    () => SaveDoctorAvailabilityUseCase(sl()),
  );
  sl.registerLazySingleton<DoctroProfileUpdateUseCase>(
    () => DoctroProfileUpdateUseCase(sl()),
  );
  sl.registerLazySingleton<GetAvailableSlotsUseCase>(
    () => GetAvailableSlotsUseCase(sl(), sl()),
  );
  sl.registerLazySingleton<BookAppointmentUseCase>(
    () => BookAppointmentUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateAppointmentsStatusUseCase>(
    () => UpdateAppointmentsStatusUseCase(sl()),
  );
  sl.registerLazySingleton<GetDoctorAppointmentsUseCase>(
    () => GetDoctorAppointmentsUseCase(sl()),
  );
  sl.registerLazySingleton<GetPatientAppointmentsUseCase>(
    () => GetPatientAppointmentsUseCase(sl()),
  );
  sl.registerLazySingleton<SubmitReviewUseCase>(
    () => SubmitReviewUseCase(sl()),
  );
  sl.registerLazySingleton<GetDoctorReviewUseCase>(
    () => GetDoctorReviewUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateUserProfileUseCase>(
    () => UpdateUserProfileUseCase(sl()),
  );
  sl.registerLazySingleton<GetChatRoomsUseCase>(
    () => GetChatRoomsUseCase(sl()),
  );
  sl.registerLazySingleton(() => AcceptCallUseCase(sl()));
  sl.registerLazySingleton(() => DeclineCallUseCase(sl()));
  sl.registerLazySingleton(() => CancelCallUseCase(sl()));
  sl.registerLazySingleton<GetMessagesUseCase>(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton<SendMessageUseCase>(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => UploadFileUseCase(sl()));
  sl.registerLazySingleton(() => InitiateCallUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      sl<LoginUsecase>(),
      sl<RegisterUsecase>(),
      sl<GetCurrentUserUseCase>(),
      sl<LogoutUseCase>(),
      sl<IsDoctorProfileExistsUseCase>(),
      sl(),
    ),
  );
  sl.registerFactory(() => DoctorProfileSetupBloc(sl(), sl()));
  sl.registerFactory(() => DoctorListBloc(sl<GetDoctorsUseCase>()));
  sl.registerFactory(
    () => DoctorProfileViewBloc(sl<GetDoctorByIdUseCase>(), sl()),
  );
  sl.registerFactory(
    () => ManageAvailabilityBloc(
      sl<GetCurrentDoctorProfileUseCase>(),
      sl<SaveDoctorAvailabilityUseCase>(),
    ),
  );
  sl.registerFactory(() => BookingBloc(sl())); // Add this line
  sl.registerFactory(() => DoctorAppointmentsBloc(sl(), sl(), sl()));
  sl.registerFactory(() => PatientAppointmentsBloc(sl(), sl(), sl()));
  sl.registerFactory(() => ReviewBloc(sl(), sl()));
  sl.registerFactory(() => DoctorProfileUpdateBloc(sl(), sl()));
  sl.registerFactory(() => ChatListBloc(sl()));
  sl.registerFactory(() => ChatRoomBloc(sl(), sl(), sl()));
  sl.registerFactory(() => CallScreenBloc(sl(), sl()));
  sl.registerFactory(() => VideoCallBloc(sl(), sl(), sl(), sl()));
  // Theme Cubit
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
}
