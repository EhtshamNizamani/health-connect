part of '../screen/home_screen.dart';

class _TopDoctorsSection extends StatelessWidget {
  const _TopDoctorsSection();

  @override
  Widget build(BuildContext context) {
    // We use BlocBuilder to listen to the DoctorListBloc
    return BlocBuilder<DoctorListBloc, DoctorListState>(
      // buildWhen is an optimization: only rebuild this section if the doctor list changes.
      buildWhen: (previous, current) => previous.doctors != current.doctors,
      builder: (context, state) {
        // --- THE FIX IS HERE ---
        // We now read the list directly from the unified DoctorListState.
        
        final allDoctors = state.doctors;

        if (allDoctors.isEmpty) {
          // If there are no doctors at all, show nothing.
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        
        // You can add logic here later to sort by rating.
        // For now, we'll just take the first few doctors from the list.
        final topDoctors = allDoctors.take(5).toList();
        
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 170, // Increased height for better look
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: topDoctors.length,
              itemBuilder: (context, index) {
                // Add some margin between the cards
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: _TopDoctorCard(doctor: topDoctors[index]),
                );
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
        elevation: 2,
        shadowColor: theme.shadowColor.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to the full profile screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DoctorProfileScreen(doctorId: doctor.uid),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35, // Slightly larger avatar
                  backgroundImage: doctor.photoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(doctor.photoUrl)
                      : null,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: doctor.photoUrl.isEmpty
                      ? Icon(Icons.person, color: theme.colorScheme.primary)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  doctor.name,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialization,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}