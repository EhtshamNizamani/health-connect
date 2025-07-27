import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_connect/core/themes/theme_manager.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_event.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/auth/presentation/auth/screens/login_screen..dart';
import 'package:health_connect/features/doctor/doctor_dashboard/screen/doctor_main_screen.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/bloc/doctor_profile_setup_bloc.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/presentation/screens/doctor_profile_setup_screen.dart';
import 'package:health_connect/features/appointment/presentation/blocs/booking_bloc.dart';
import 'package:health_connect/features/patient/dashboard/screens/dashboard_screen.dart';

import 'core/di/service_locator.dart';
import 'features/auth/presentation/auth/blocs/auth_bloc.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setupLocator();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<DoctorProfileSetupBloc>(
          create: (_) => sl<DoctorProfileSetupBloc>(),
        ),
        BlocProvider<BookingBloc>(create: (_) => sl<BookingBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) {
            // The listener is now a parent of MaterialApp
            return BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                print("Global Auth Listener received state: $state");
                final navigator = _navigatorKey.currentState;
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
                navigatorKey: _navigatorKey, // Use the global key
                debugShowCheckedModeBanner: false,
                theme: themeState.themeData,
                // The home is now a simple, static splash screen.
                // The listener will navigate away from it.
                home: const SplashScreen(),
              ),
            );
          },
        );
      },
    );
  }
}

// Ek simple Splash Screen Widget
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
