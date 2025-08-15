

import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color;
    final String text;

    switch (status) {
      case 'pending':
        color = Colors.orange.shade700;
        text = 'Pending';
        break;
      case 'confirmed':
        color = Colors.green.shade700;
        text = 'Confirmed';
        break;
      case 'completed':
        color = theme.colorScheme.primary;
        text = 'Completed';
        break;
      default:
        color = theme.colorScheme.outline;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}