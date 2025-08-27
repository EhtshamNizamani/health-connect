import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_connect/core/config/zego_cloud_config.dart';
import 'package:health_connect/core/services/notification_service.dart';
import 'package:health_connect/core/services/sound_service.dart';
import 'package:health_connect/core/services/stripe_payment_service.dart';
import 'package:health_connect/core/themes/theme_manager.dart';
import 'package:health_connect/features/appointment/domain/usecases/get_doctor_appointments_usecase.dart';
import 'package:health_connect/features/appointment/domain/usecases/get_patient_appointments_usecase.dart';
import 'package:health_connect/features/appointment/domain/usecases/initiate_payment.dart';
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
import 'package:health_connect/features/chat/domain/usecases/get_total_unread_count_usecase.dart';
import 'package:health_connect/features/chat/domain/usecases/mark_chat_room_as_read_usecase.dart';
import 'package:health_connect/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:health_connect/features/chat/domain/usecases/upload_file_usecase.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_bloc.dart';
import 'package:health_connect/features/chat_access/bloc/chat_access_bloc.dart';
import 'package:health_connect/features/doctor/appointment/presantation/bloc/doctor_appointments_bloc.dart';
import 'package:health_connect/features/doctor/appointment_detail/data/repository_impl/appointment_detail_repository_impl.dart';
import 'package:health_connect/features/doctor/appointment_detail/domain/repository/appointment_detail_repository.dart';
import 'package:health_connect/features/doctor/appointment_detail/domain/usecase/get_appointment_details_usecase.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/bloc/appointment_details_bloc.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/data/repository/doctor_dashboard_repository_impl.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/domain/repository/doctor_dashboard_repository.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/domain/usecase/get_doctor_dashboard_data_usecase.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/presantation/bloc/doctor_dashboard_bloc.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/data/repositories_impl/doctor_profile_repository_impl.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/repositories/doctor_profile_repository.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/usecase/get_current_doctor_profile_usecase.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/usecase/save_doctor_usecase.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/bloc/doctor_profile_setup_bloc.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/data/repository/doctor_profile_update_repository_impl.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/domain/repository/doctor_profile_update_repository.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/domain/usecase/doctor_profile_update_usecase.dart';
import 'package:health_connect/features/doctor/doctor_profile_update/presantation/bloc/doctor_profile_update_bloc.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/data/repository_impl/edit_appointment_summary_repository_impl.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/domain/repository/edit_appointment_summary_repository.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/domain/usecase/edit_appointment_summary.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/domain/usecase/upload_files_usecase.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/presantation/bloc/edit_summary_bloc.dart';
import 'package:health_connect/features/doctor/manage_availability/data/repository/firebase_%20manage_availability_repository_impl.dart';
import 'package:health_connect/features/doctor/manage_availability/domain/repository/manage_availability_repository.dart';
import 'package:health_connect/features/doctor/manage_availability/domain/usecase/save_doctor_availability_usecase.dart';
import 'package:health_connect/features/doctor/manage_availability/presantation/bloc/manage_availability_bloc.dart';
import 'package:health_connect/features/appointment/data/repositories/appointment_repository_impl.dart';
import 'package:health_connect/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:health_connect/features/appointment/domain/usecases/book_appointment_usecase.dart';
import 'package:health_connect/features/appointment/presentation/blocs/booking_bloc.dart';
import 'package:health_connect/features/doctor/patient_details/data/patient_details_repository_impl/patient_detail_repository_impl.dart';
import 'package:health_connect/features/doctor/patient_details/domain/repository/patient_details_repository.dart';
import 'package:health_connect/features/doctor/patient_details/domain/usecases/get_patient_details_usecase.dart';
import 'package:health_connect/features/doctor/patient_details/presantation/bloc/patient_details_bloc.dart';
import 'package:health_connect/features/doctor/patient_records/data/repository_impl/patient_records_repository_impl.dart';
import 'package:health_connect/features/doctor/patient_records/domain/repository/patient_records_repository.dart';
import 'package:health_connect/features/doctor/patient_records/domain/usecase/get_patients_for_doctor_usecase.dart';
import 'package:health_connect/features/doctor/patient_records/presentation/bloc/patient_records_bloc.dart';
import 'package:health_connect/features/doctor/review/data/repository/review_repository_impl.dart';
import 'package:health_connect/features/doctor/review/domain/repository/review_repository.dart';
import 'package:health_connect/features/doctor/review/domain/usecase/get_doctor_review_usecase.dart';
import 'package:health_connect/features/doctor/review/domain/usecase/submit_review_usecase.dart';
import 'package:health_connect/features/doctor/review/presantation/bloc/review_bloc.dart';
import 'package:health_connect/features/notification/data/repository_impl/notificaiton_impl.dart';
import 'package:health_connect/features/notification/domain/repository/notification_repository.dart';
import 'package:health_connect/features/notification/domain/usecase/get_unread_count_usecase.dart';
import 'package:health_connect/features/notification/domain/usecase/mark_notification_as_read_usecase.dart';
import 'package:health_connect/features/notification/presantaion/bloc/notification_bloc.dart';
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
import 'package:health_connect/features/patient/medical_info/data/repository_impl/update_patient_medical_info_repository_impl.dart';
import 'package:health_connect/features/patient/medical_info/domain/repository/update_patient_medical_info_repository.dart';
import 'package:health_connect/features/patient/medical_info/presentation/bloc/update_medical_info_bloc_bloc.dart';
import 'package:health_connect/features/patient/profile/data/repositories_impl/patient_profile_repository_impl.dart';
import 'package:health_connect/features/patient/profile/domain/uscecases/update_patient_profile_usecase.dart';
import 'package:health_connect/features/patient/profile/presantation/bloc/patient_profile_bloc.dart';
import 'package:health_connect/features/video_call/data/repository/call_engine_repository_impl.dart.dart';
import 'package:health_connect/features/video_call/data/repository/calling_repository_impl.dart';
import 'package:health_connect/features/video_call/data/repository/video_call_repository_impl.dart';
import 'package:health_connect/features/video_call/domain/repository/call_engine_repository.dart';
import 'package:health_connect/features/video_call/domain/repository/calling_repository.dart';
import 'package:health_connect/features/video_call/domain/repository/video_call_repository.dart';
import 'package:health_connect/features/video_call/domain/usecase/accept_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/cancel_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/decline_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/initiate_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/manage_call_usecase.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/video_call_bloc.dart';
import 'package:health_connect/features/patient/profile/domain/repositories/patient_profile_repository.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Load environment variables first
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

  //service
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => StripePaymentService());
  sl.registerLazySingleton(() => SoundService());

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
    () => AppointmentRepositoryImpl(sl(), sl()),
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
  sl.registerLazySingleton<CallingRepository>(
    () => CallingRepositoryImpl(sl<FirebaseFunctions>(), sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DoctorDashboardRepository>(
    () => DoctorDashboardRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AppointmentDetailRepository>(
    () => AppointmentDetailRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<EditAppointmentSummaryRepository>(
    () => EditAppointmentSummaryRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<PatientRecordsRepository>(
    () => PatientRecordsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PatientDetailRepository>(
    () => PatientDetailRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<UpdatePatientMedicalInfoRepository>(
    () => UpdatePatientMedicalInfoRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<PatientProfileRepository>(
    () => PatientProfileRepositoryImpl(sl(), sl()),
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
  sl.registerLazySingleton<MarkChatRoomAsReadOptimisticUseCase>(
    () => MarkChatRoomAsReadOptimisticUseCase(sl()),
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
  sl.registerLazySingleton(() => InitiatePaymentUseCase(sl()));
  sl.registerLazySingleton(() => ManageCallUseCase(sl(), sl()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationsAsReadUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorDashboardDataUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalUnreadCountUseCase(sl()));
  sl.registerLazySingleton(() => MarkChatRoomAsReadUseCase(sl()));
  sl.registerLazySingleton(() => ChatRoomOptimisticUpdater(sl()));
  sl.registerLazySingleton(() => GetAppointmentDetailsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAppointmentSummaryUseCase(sl()));
  sl.registerLazySingleton(() => UploadFilesUseCase(sl()));
  sl.registerLazySingleton(() => GetPatientDetailsUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePatientProfileUseCase(sl()));

  // Bloc - CHANGED: AuthBloc as LazySingleton instead of Factory
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      sl<LoginUsecase>(),
      sl<RegisterUsecase>(),
      sl<GetCurrentUserUseCase>(),
      sl<LogoutUseCase>(),
      sl<IsDoctorProfileExistsUseCase>(),
      sl(),
    ),
  );
  sl.registerLazySingleton(() => GetPatientsForDoctorUseCase(sl()));
  sl.registerFactory(() => PatientProfileBloc(sl(), sl()));

  sl.registerLazySingleton<NotificationBloc>(
    () => NotificationBloc(sl(), sl(), sl<AuthBloc>(), sl()),
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
  sl.registerFactory(() => BookingBloc(sl(), sl(), sl()));
  sl.registerFactory(() => DoctorAppointmentsBloc(sl(), sl(), sl()));
  sl.registerFactory(() => PatientAppointmentsBloc(sl(), sl(), sl()));
  sl.registerFactory(() => ReviewBloc(sl(), sl()));
  sl.registerFactory(() => DoctorProfileUpdateBloc(sl(), sl()));
  sl.registerFactory(() => ChatListBloc(sl(), sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory(() => ChatRoomBloc(sl(), sl(), sl()));
  sl.registerFactory(() => CallScreenBloc(sl(), sl()));
  sl.registerFactory(() => VideoCallBloc(sl(), sl(), sl(), sl()));
  sl.registerFactory(() => DoctorDashboardBloc(sl(), sl()));
  sl.registerFactory(() => AppointmentDetailBloc(sl()));
  sl.registerFactory(() => UpdateMedicalInfoBloc(sl(), sl()));

  sl.registerFactory<ChatAccessBloc>(
    () => ChatAccessBloc(
      sl<GetPatientAppointmentsUseCase>(),
      sl<GetDoctorAppointmentsUseCase>(),
    ),
  );
  sl.registerFactory(
    () => EditSummaryBloc(updateSummaryUseCase: sl(), uploadFilesUseCase: sl()),
  );
  sl.registerFactory(() => PatientRecordsBloc(sl(), sl()));
  sl.registerFactory(() => PatientDetailBloc(sl()));

  // Theme Cubit
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
}
