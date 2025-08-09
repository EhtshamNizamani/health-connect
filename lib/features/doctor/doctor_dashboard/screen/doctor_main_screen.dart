import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:health_connect/features/doctor/appointment/presantation/screen/doctor_appointments_screen.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/cubit/doctor_nav_cubit.dart';
import 'package:health_connect/features/doctor/home/doctor_home_screen.dart';
import 'package:health_connect/features/doctor/doctor_setings/preesntaion/screens/doctor_setings_screen.dart';
import 'package:health_connect/features/notification/presantaion/bloc/notification_bloc.dart';

class DoctorMainScreen extends StatelessWidget {
  const DoctorMainScreen({super.key});

  // The list of screens for the navigation tabs
  final List<Widget> screens = const [
    DoctorHomeScreen(),
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
                  // Use a BlocBuilder to listen to the GLOBAL bloc
                  icon: BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (context, state) {
                      return AnimatedBadgeIcon(
                        triggerKey: state.unreadCount,
                        child: Badge(
                          isLabelVisible: state.unreadCount > 0,
                          label: Text(state.unreadCount.toString()),
                          child:  Icon(Icons.calendar_today_outlined,size: 24.r ),
                        ),
                      ); // Ek halki si chamak
                    },
                  ),
                  activeIcon:  Icon(Icons.calendar_today ,size: 24.r),
                  label: 'Appointments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_outlined, size: 24.r),
                  activeIcon: Icon(Icons.chat_bubble_outline, size: 24.r),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.settings_outlined,
                    size: 24.r,
                  ), // Using settings icon
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

class AnimatedBadgeIcon extends StatefulWidget {
  final Widget child;
  final int triggerKey;

  const AnimatedBadgeIcon({
    super.key,
    required this.child,
    required this.triggerKey,
  });

  @override
  State<AnimatedBadgeIcon> createState() => _AnimatedBadgeIconState();
}

class _AnimatedBadgeIconState extends State<AnimatedBadgeIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant AnimatedBadgeIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerKey != oldWidget.triggerKey) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
