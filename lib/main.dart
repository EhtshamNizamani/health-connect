// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/core/themes/theme_manager.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_event.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/auth/presentation/auth/screens/login_screen..dart';
import 'package:health_connect/features/auth/presentation/doctor_dashboard/doctor_dashboard_screen.dart';
import 'package:health_connect/features/dashboard/screens/dashboard_screen.dart';

import 'core/di/service_locator.dart';
import 'features/auth/presentation/auth/blocs/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await setupLocator(); // 🧠 Inject dependencies

  runApp(ScreenUtilInit(
        designSize: Size(375, 812), // iPhone X base design
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return const MyApp(); // Your main app widget
        },
      ),);
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeState.themeData,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthInitial) {
                  return const Scaffold(
                    body: Center(child: Text("Splash Screen")),
                  );
                } else if (authState is Authenticated) {
                  if (authState.user.role == 'doctor') {
                    return const DoctorDashboardScreen();
                  } else {
                    return const DashboardScreen(); // Patient dashboard
                  }
                } else if (authState is Unauthenticated) {
                  return const LoginScreen();
                } else {
                  return const LoginScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
