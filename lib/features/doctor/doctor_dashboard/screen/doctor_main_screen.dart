import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/features/doctor/appointment/presantation/screen/doctor_appointments_screen.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/cubit/doctor_nav_cubit.dart';
import 'package:health_connect/features/doctor/home/doctor_home_screen.dart';
import 'package:health_connect/features/doctor/setings/preesntaion/screens/setings_screen.dart';

class DoctorMainScreen extends StatelessWidget {
  const DoctorMainScreen({super.key});

  // The list of screens for the navigation tabs
  final List<Widget> screens = const [
    DoctorHomeScreen(),
    DoctorAppointmentsScreen(),
    Text("DoctorPatientsScreen"),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Get the current theme from the context
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => DoctorBottomNavCubit(),
      child: BlocBuilder<DoctorBottomNavCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            // Use IndexedStack to keep the state of each screen alive
            // when switching tabs. This prevents data from reloading
            // every time you switch back and forth.
            body: IndexedStack(
              index: currentIndex,
              children: screens,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) =>
                  context.read<DoctorBottomNavCubit>().changeTab(index),
              
              // === THEME STYLING ===
              backgroundColor: theme.colorScheme.surface, // Use surface color for the bar's background
              type: BottomNavigationBarType.fixed, // Good for 3-5 items
              
              // Selected item styling
              selectedItemColor: theme.colorScheme.primary,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              
              // Unselected item styling
              unselectedItemColor: theme.colorScheme.outline,
              showUnselectedLabels: true,
              
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined, size: 24.r),
                  activeIcon: Icon(Icons.dashboard, size: 24.r),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined, size: 24.r),
                  activeIcon: Icon(Icons.calendar_today, size: 24.r),
                  label: 'Appointments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_outlined, size: 24.r),
                  activeIcon: Icon(Icons.people_alt, size: 24.r),
                  label: 'Patients',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined, size: 24.r), // Using settings icon
                  activeIcon: Icon(Icons.settings, size: 24.r),
                  label: 'Settings', // Changed label to 'Settings'
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}