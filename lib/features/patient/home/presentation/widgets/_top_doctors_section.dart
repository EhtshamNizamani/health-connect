part of '../screen/home_screen.dart';

class _TopDoctorsSection extends StatelessWidget {
  const _TopDoctorsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorListBloc, DoctorListState>(
      builder: (context, state) {
        if (state.doctors.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        // Show only the top 3 doctors, for example
        final topDoctors = state.doctors.take(3).toList();
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 160, // Adjust height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: topDoctors.length,
              itemBuilder: (context, index) {
                return _TopDoctorCard(doctor: topDoctors[index]);
              },
            ),
          ),
        );
      },
    );
  }
}

class _TopDoctorCard extends StatelessWidget {
  final DoctorEntity doctor;
  const _TopDoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 130,
      child: Card(
        elevation: 1,
        shadowColor: theme.shadowColor.withAlpha(01),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
  Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DoctorProfileScreen(doctorId: doctor.uid),
              ),
            );          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               CircleAvatar(
              radius: 30,
              backgroundImage: doctor.photoUrl.isNotEmpty
                  ? CachedNetworkImageProvider(doctor.photoUrl) // Yahan badlav karein
                  : null,
              backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
              child: doctor.photoUrl.isEmpty ? const Icon(Icons.person) : null,
            ),
                const SizedBox(height: 8),
                Text(doctor.name, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(doctor.specialization, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}