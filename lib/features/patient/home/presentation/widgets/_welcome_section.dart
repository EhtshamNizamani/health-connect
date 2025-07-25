part of '../screen/home_screen.dart';

class _WelcomeSection extends StatelessWidget {
  final String userName;
  const _WelcomeSection({required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      pinned: true,
      title: Text(
        'Good Morning, $userName!',
        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: theme.colorScheme.onBackground),
          onPressed: () {},
        ),
      ],
    );
  }
}