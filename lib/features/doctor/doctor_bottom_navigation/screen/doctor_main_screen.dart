import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/core/shared/widgets/notification_badge_icon.dart';
import 'package:health_connect/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:health_connect/features/doctor/appointment/presantation/screen/doctor_appointments_screen.dart';
import 'package:health_connect/features/doctor/doctor_bottom_navigation/cubit/doctor_nav_cubit.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/presantation/screens/doctor_dashboard_screen.dart';
import 'package:health_connect/features/doctor/doctor_setings/preesntaion/screens/doctor_setings_screen.dart';
import 'package:health_connect/features/notification/presantaion/bloc/notification_bloc.dart';

class DoctorMainScreen extends StatelessWidget {
  const DoctorMainScreen({super.key});

  // The list of screens for the navigation tabs
  final List<Widget> screens = const [
    DoctorDashboardScreen(),
    DoctorAppointmentsScreen(),
    ChatListScreen(),
    DoctorSettingsScreen(),
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
            body: IndexedStack(index: currentIndex, children: screens),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                if (index == 1) {
                  // This is correct: dispatch the event to the GLOBAL bloc
                  context.read<NotificationBloc>().add(
                    MarkNotificationsAsRead(),
                  );
                }
                context.read<DoctorBottomNavCubit>().changeTab(index);
              },

              // === THEME STYLING ===
              backgroundColor: theme
                  .colorScheme
                  .surface, // Use surface color for the bar's background
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
                  icon: NotificationBadgeIcon(
                    iconData: Icons.calendar_today_outlined,
                    size: 24.r,
                    type: NotificationBadgeType.appointments,
                  ),
                  label: 'Appointments',
                ),
                BottomNavigationBarItem(
                  icon: NotificationBadgeIcon(
                    iconData: Icons.chat_bubble_outline,
                    size: 24.r,
                    type: NotificationBadgeType.messages,
                  ),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.settings_outlined,
                    size: 24.r,
                  ), 
                  activeIcon: Icon(Icons.settings, size: 24.r),
                  label: 'Settings', 
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
