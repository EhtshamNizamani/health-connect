part of '../screen/home_screen.dart'; // Make sure this path is correct
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by doctor name or specialty...", // Updated hint
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.outline),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
                // <<< --- CONNECT THE TEXTFIELD TO THE BLOC ---
                onChanged: (value) {
                  // On every keystroke, add the SearchQueryChanged event
                  context.read<DoctorListBloc>().add(SearchQueryChanged(value));
                },
              ),
            ),
            // The filter button on the right
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () {
                  // TODO: Show a filter dialog or bottom sheet
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}