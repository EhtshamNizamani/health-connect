part of '../screen/home_screen.dart';

class _SpecialtiesSection extends StatelessWidget {
  const _SpecialtiesSection();

  @override
  Widget build(BuildContext context) {
    // Dummy data for now
    final specialties = [
      {'icon': Icons.favorite_border, 'label': 'Cardiology'},
      {'icon': Icons.visibility_outlined, 'label': 'Ophthalmology'},
      {'icon': Icons.child_friendly, 'label': 'Pediatrics'},
      {'icon': Icons.psychology_outlined, 'label': 'Neurology'},
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: specialties.length,
          itemBuilder: (context, index) {
            final item = specialties[index];
            return _SpecialtyCard(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
            );
          },
        ),
      ),
    );
  }
}

class _SpecialtyCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecialtyCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}