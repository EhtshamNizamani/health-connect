import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/shared/widgets/custom_text_widget.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_event.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current theme from the context
    final theme = Theme.of(context);

    return Scaffold(
      // Use scaffoldBackgroundColor from the theme
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // Use appBarTheme from the theme
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Doctor Dashboard',
          // Use appBarTheme's titleTextStyle from the theme
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            // Use appBarTheme's iconTheme from the theme for consistent icon color
            icon: Icon(Icons.logout, color: theme.appBarTheme.iconTheme?.color),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // This widget already uses theme colors, which is good.
             CustomTextWidget(
              text: "Welcome Doctor 👨‍⚕️",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Use a color from the theme's colorScheme. 'primaryContainer'
                // is a good choice for backgrounds that are related to the primary color.
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomTextWidget(
                text: "📅 Upcoming Appointments: 3\n🧑‍🤝‍🧑 Total Patients: 12",
                fontSize: 16,
                // Use a color from the theme's colorScheme that is meant for text on 'primaryContainer'.
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            const CustomTextWidget(
              text: "Quick Actions",
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ActionCard(title: "View Appointments", icon: Icons.calendar_today),
                ActionCard(title: "Patient Records", icon: Icons.folder_shared),
                ActionCard(title: "Messages", icon: Icons.message),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
  });
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // Get the current theme from the context
    final theme = Theme.of(context);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Use a background color from the theme. 'surface' is a good
        // choice for card-like elements.
        color: theme.colorScheme.surface,
        border: Border.all(
          // The border color can be 'outline' or a faint primary color
          color: theme.colorScheme.outline.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // The shadow color should be very faint
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The icon color should be the primary theme color
          Icon(icon, size: 28, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            // Use the text theme for consistency
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}