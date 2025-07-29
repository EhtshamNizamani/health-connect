import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/features/doctor/review/domain/entity/review_entity.dart';
import 'package:intl/intl.dart';

class ReviewCard extends StatelessWidget {
  final ReviewEntity review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Format the date as seen in the UI (e.g., 28/7/2025)
    final formattedDate = DateFormat('d/M/yyyy').format(review.timestamp.toDate());

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        // Use a very light background to distinguish it, or keep it transparent
        color: theme.colorScheme.surface, 
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Initial Circle Avatar
              CircleAvatar(
                radius: 22.r,
                // Use the primary color from the theme for the background
                backgroundColor: theme.colorScheme.primary.withOpacity(0.8),
                child: Text(
                  // Get the first letter of the patient's name, or 'A' if empty
                  review.patientName.isNotEmpty ? review.patientName[0].toUpperCase() : 'A',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    // Use the color meant for text on top of the primary color
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Name
                    Text(
                      review.patientName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Star Rating
                    Row(
                      children: [
                        Text(
                          review.rating.toStringAsFixed(1), // e.g., "4.5"
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            // Use a distinct color for the rating number
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.star,
                          color: Colors.amber.shade600,
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Date on the right
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          // Review Comment
          Padding(
            padding: EdgeInsets.only(left: 56.w), // Align with the text above the avatar
            child: Text(
              review.comment,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                height: 1.4, // Improve line spacing for readability
              ),
            ),
          ),
        ],
      ),
    );
  }
}