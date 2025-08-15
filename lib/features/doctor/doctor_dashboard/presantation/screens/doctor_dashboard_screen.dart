import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_event.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_list/chat_list_state.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/domain/entities/doctor_dashboard_entity.dart';
import 'package:health_connect/features/doctor/doctor_dashboard/presantation/bloc/doctor_dashboard_bloc.dart';
import 'package:health_connect/features/doctor/manage_availability/presantation/screen/manage_availability_screen.dart';
import 'package:health_connect/features/doctor/doctor_bottom_navigation/cubit/doctor_nav_cubit.dart';
import 'package:health_connect/features/notification/presantaion/bloc/notification_bloc.dart';
import 'package:intl/intl.dart'; 
import 'package:shimmer/shimmer.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final doctorName = authState.user?.name ?? "Doctor";

    // Wrap the entire screen with the new BLoC provider
    return BlocProvider(
      create: (context) => sl<DoctorDashboardBloc>()..add(FetchDashboardData()),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
      
        body: SafeArea(
          child: BlocBuilder<DoctorDashboardBloc, DoctorDashboardState>(
            builder: (context, state) {
              // State 1: Loading -> Show Skeleton UI
              if (state is DoctorDashboardLoading || state is DoctorDashboardInitial) {
                return _DashboardSkeleton(doctorName: doctorName);
              }
          
              // State 2: Error -> Show Error Message
              if (state is DoctorDashboardError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(state.message, textAlign: TextAlign.center),
                  ),
                );
              }
          
              // State 3: Loaded -> Show Real Data
              if (state is DoctorDashboardLoaded) {
                final dashboardData = state.dashboardData;
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<DoctorDashboardBloc>().add(FetchDashboardData());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WelcomeHeader(doctorName: doctorName),
                        const SizedBox(height: 24),
                        _TodaysSnapshotCard(data: dashboardData),
                        const SizedBox(height: 24),
                        const _SectionHeader(title: "Quick Actions"),
                        const SizedBox(height: 16),
                        const _QuickActionsGrid(),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          title: "Today's Agenda",
                          onViewAll: () => context.read<DoctorBottomNavCubit>().changeTab(1),
                        ),
                        const SizedBox(height: 16),
                        _TodaysAgendaList(agenda: dashboardData.todaysAgenda),
                        const SizedBox(height: 24),
                        // Performance Glance can be added later
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              }
          
              return const SizedBox.shrink(); // Fallback for any other state
            },
          ),
        ),
      ),
    );
  }
}

// --- MAIN SKELETON WIDGET ---
class _DashboardSkeleton extends StatelessWidget {
  final String doctorName;
  const _DashboardSkeleton({required this.doctorName});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeHeader(doctorName: doctorName),
            const SizedBox(height: 24),
            _buildSkeletonCard(height: 150),
            const SizedBox(height: 24),
            const _SectionHeader(title: "Quick Actions"),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildSkeletonCard(),
                _buildSkeletonCard(),
                _buildSkeletonCard(),
                _buildSkeletonCard(),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: "Today's Agenda"),
            const SizedBox(height: 16),
            _buildSkeletonCard(height: 200),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard({double? height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// --- WIDGETS (Updated to use dynamic data) ---

class _WelcomeHeader extends StatelessWidget {
  final String doctorName;
  const _WelcomeHeader({required this.doctorName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Hello Dr. $doctorName! 👋",
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold,fontSize: 22),
      ),
    );
  }
}

class _TodaysSnapshotCard extends StatelessWidget {
  final DoctorDashboardEntity data;
  const _TodaysSnapshotCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextAppointmentText = data.nextAppointment != null
        ? "${data.nextAppointment!.patientName} @ ${DateFormat('hh:mm a').format(data.nextAppointment!.appointmentDateTime)}"
        : "No more appointments";

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, notificationState) {
          return Column(
            children: [
              _StatRow(
                icon: CupertinoIcons.calendar_today,
                title: "Today's Appointments",
                value: data.todaysAppointmentsCount.toString(),
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const Divider(height: 16),
              _StatRow(
                icon: CupertinoIcons.time,
                title: "Next Up",
                value: nextAppointmentText,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const Divider(height: 16),
              _StatRow(
                icon: CupertinoIcons.bell_fill,
                title: "New Requests",
                value: "${notificationState.unreadCount} (Needs review)",
                valueColor: notificationState.unreadCount > 0
                    ? theme.colorScheme.error
                    : theme.colorScheme.onPrimaryContainer,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickActionsGrid extends StatefulWidget {
  const _QuickActionsGrid();

  @override
  State<_QuickActionsGrid> createState() => _QuickActionsGridState();
}

class _QuickActionsGridState extends State<_QuickActionsGrid> {
  @override
  void initState() {
    super.initState();
    // Initialize chat list subscription when this widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure chat list bloc is subscribed to get unread counts
      context.read<ChatListBloc>().add(SubscribeToChatRooms());
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        // Appointments with notification badge
        BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            return _ActionCard(
              title: "View Appointments",
              icon: CupertinoIcons.calendar_badge_plus,
              badgeCount: state.unreadCount,
              onTap: () {
                context.read<NotificationBloc>().add(MarkNotificationsAsRead());
                context.read<DoctorBottomNavCubit>().changeTab(1);
              },
            );
          },
        ),

        // Manage Availability
        _ActionCard(
          title: "Manage Availability",
          icon: CupertinoIcons.clock_fill,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const ManageAvailabilityScreen(),
            ));
          },
        ),

        // Messages with unread count badge
        BlocConsumer<ChatListBloc, ChatListState>(
          listener: (context, state) {
            // Log state changes for debugging
            print("🖥️ [QuickActions] ChatListBloc state changed to: ${state.runtimeType}");
            if (state is ChatListLoaded) {
              print("🖥️ [QuickActions] Total unread messages: ${state.totalUnreadCount}");
            }
          },
          builder: (context, state) {
            int unreadMessages = 0;
            
            if (state is ChatListLoaded) {
              unreadMessages = state.totalUnreadCount;
            } else if (state is ChatListError) {
              print("❌ [QuickActions] ChatListBloc error: ${state.message}");
            }

            return _ActionCard(
              title: "Messages",
              icon: CupertinoIcons.chat_bubble_2_fill,
              badgeCount: unreadMessages,
              onTap: () {
                // Navigate to messages tab
                context.read<DoctorBottomNavCubit>().changeTab(2);
              },
            );
          },
        ),

        // Patient Records
        _ActionCard(
          title: "Patient Records",
          icon: CupertinoIcons.person_3_fill,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("This feature is coming soon!")),
            );
          },
        ),
      ],
    );
  }
}

class _TodaysAgendaList extends StatelessWidget {
  final List<dynamic> agenda;
  const _TodaysAgendaList({required this.agenda});

  @override
  Widget build(BuildContext context) {
    if (agenda.isEmpty) {
      return const Center(child: Text("No appointments scheduled for today."));
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListView.separated(
        itemCount: agenda.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final appointment = agenda[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(CupertinoIcons.person_fill)),
            title: Text(appointment.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(appointment.status, style: TextStyle(color: _getStatusColor(appointment.status, Theme.of(context)))),
            trailing: Text(DateFormat('hh:mm a').format(appointment.appointmentDateTime),
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            onTap: () {},
          );
        },
      ),
    );
  }
  
  Color _getStatusColor(String status, ThemeData theme) {
    // A helper for status colors in the agenda list
    switch (status) {
      case 'pending': return Colors.orange.shade700;
      case 'confirmed': return Colors.green.shade700;
      default: return theme.colorScheme.outline;
    }
  }
}


class _StatRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? color;
  final Color? valueColor;

  const _StatRow({
    required this.icon,
    required this.title,
    required this.value,
    this.color,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: color ?? theme.textTheme.bodyMedium?.color, size: 20),
        const SizedBox(width: 12),
        Text(title, style: TextStyle(color: color, fontSize: 16)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (onViewAll != null)
          TextButton(onPressed: onViewAll, child: const Text("View All")),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Badge(label: Text(badgeCount.toString())),
              ),
          ],
        ),
      ),
    );
  }
}


class _PerformanceGlanceCard extends StatelessWidget {
  const _PerformanceGlanceCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.dividerColor),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatColumn(
            icon: CupertinoIcons.money_dollar_circle,
            value: "₹12,500",
            label: "This Week",
          ),
          _StatColumn(
            icon: CupertinoIcons.star_fill,
            value: "4.8",
            label: "Rating",
          ),
          _StatColumn(
            icon: CupertinoIcons.checkmark_seal_fill,
            value: "95%",
            label: "Completed",
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.secondary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
