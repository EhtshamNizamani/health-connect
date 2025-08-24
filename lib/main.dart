import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:health_connect/core/services/notification_service.dart';
import 'package:health_connect/core/themes/theme_manager.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_event.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/auth/presentation/auth/screens/login_screen..dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_event.dart';
import 'package:health_connect/features/chat_access/bloc/chat_access_bloc.dart';
import 'package:health_connect/features/doctor/appointment/presantation/bloc/doctor_appointments_bloc.dart';
import 'package:health_connect/features/doctor/doctor_bottom_navigation/screen/doctor_main_screen.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/bloc/doctor_profile_setup_bloc.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/screens/doctor_profile_setup_screen.dart';
import 'package:health_connect/features/appointment/presentation/blocs/booking_bloc.dart';
import 'package:health_connect/features/doctor/review/presantation/bloc/review_bloc.dart';
import 'package:health_connect/features/notification/presantaion/bloc/notification_bloc.dart';
import 'package:health_connect/features/patient/appointment/presentation/bloc/patient_appointments_bloc.dart';
import 'package:health_connect/features/patient/dashboard/screens/dashboard_screen.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_bloc.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/video_call_bloc.dart';

import 'core/di/service_locator.dart';
import 'features/auth/presentation/auth/blocs/auth_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  await setupLocator();
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  await Stripe.instance.applySettings();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        // Use singleton AuthBloc
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        // Use singleton NotificationBloc (it already has the same AuthBloc instance)
        BlocProvider<NotificationBloc>(
          create: (_) => sl<NotificationBloc>()..add(StartListeningToNotifications()),
        ),
        BlocProvider<DoctorProfileSetupBloc>(
          create: (_) => sl<DoctorProfileSetupBloc>(),
        ),
        BlocProvider<BookingBloc>(create: (_) => sl<BookingBloc>()),
        BlocProvider<ReviewBloc>(create: (_) => sl<ReviewBloc>()),
        BlocProvider<CallScreenBloc>(create: (_) => sl<CallScreenBloc>()),
        BlocProvider<VideoCallBloc>(create: (_) => sl<VideoCallBloc>()),
        BlocProvider<ChatListBloc>(create: (_) => sl<ChatListBloc>()),
        BlocProvider<ChatAccessBloc>(create: (_) => sl<ChatAccessBloc>()),
        BlocProvider<PatientAppointmentsBloc>(create: (_) => sl<PatientAppointmentsBloc>()),
        BlocProvider<DoctorAppointmentsBloc>(create: (_) => sl<DoctorAppointmentsBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final notificationService = sl<NotificationService>();
    await notificationService.initializeListeners();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) {
            return BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                print("Global Auth Listener received state: $state");
                final navigator = navigatorKey.currentState;
                if (navigator == null) return;

                if (state is Unauthenticated) {
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                } else if (state is AuthenticatedPatient) {
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    (route) => false,
                  );
                } else if (state is AuthenticatedDoctorProfileExists) {
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const DoctorMainScreen()),
                    (route) => false,
                  );
                } else if (state is AuthenticatedDoctorProfileNotExists) {
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const DoctorProfileSetupScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                theme: themeState.themeData,
                home: const SplashScreen(),
              ),
            );
          },
        );
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}