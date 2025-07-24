import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  final String bio;

  const AboutSection({
    super.key, 
    required this.bio
  });

  @override
  Widget build(BuildContext context) {
    // Get the current theme from the context
    final theme = Theme.of(context);

    // Use a Column to stack the title and the bio text
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
      children: [
        // Section Title
        Text(
          "About Doctor",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8), // Space between title and bio

        // Doctor's Biography Text
        Text(
        bio.isNotEmpty 
              ? bio 
              : "No biography provided by the doctor.", // Fallback text
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5, // Increases the space between lines for better readability
            color: theme.colorScheme.onBackground.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}