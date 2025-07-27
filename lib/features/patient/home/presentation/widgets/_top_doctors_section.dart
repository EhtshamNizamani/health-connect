part of '../screen/home_screen.dart';

class _TopDoctorsSection extends StatelessWidget {
  const _TopDoctorsSection();

  @override
  Widget build(BuildContext context) {
    // We use BlocBuilder to listen to the DoctorListBloc
    return BlocBuilder<DoctorListBloc, DoctorListState>(
      builder: (context, state) {
        
        // <<< --- THE FIX IS HERE ---
        // First, check if the state is actually the 'Loaded' state.
        // If it's not loaded (e.g., it's Initial, Loading, or Error),
        // we should not try to access any doctor list.
        if (state is DoctorListLoaded) {
          
          // Now that we know the state is 'Loaded', we can safely access its properties.
          final allDoctors = state.allDoctors; // Use the unfiltered list

          // If the list of all doctors is empty, show nothing.
          if (allDoctors.isEmpty) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          
          // Now, take the top-rated or first few doctors to display.
          // For now, let's just take the first 3.
          final topDoctors = allDoctors.take(3).toList();
          
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
        }
        
        // If the state is NOT DoctorListLoaded (i.e., it's Loading or Error),
        // we return an empty Sliver so it doesn't take up any space.
        return const SliverToBoxAdapter(child: SizedBox.shrink());
        // <<< ----------------------
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