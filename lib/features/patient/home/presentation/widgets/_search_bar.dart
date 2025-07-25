part of '../screen/home_screen.dart'; // Make sure this path is correct

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    // Get the current theme from the context
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // The main search text field
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by doctor, specialty...",
                  hintStyle: TextStyle(color: theme.colorScheme.outline),
                  // The search icon on the left
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.outline),
                  // Styling
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  // Border styling
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // No border by default
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
                onChanged: (value) {
                  // TODO: Implement live search logic here
                },
              ),
            ),
            const SizedBox(width: 12),
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