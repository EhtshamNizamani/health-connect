part of '../screen/home_screen.dart';

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? actionWidget;

  const _SectionHeader({required this.title, this.actionWidget});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (actionWidget != null) actionWidget!,
          ],
        ),
      ),
    );
  }
}
