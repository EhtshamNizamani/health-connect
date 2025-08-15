import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_connect/features/doctor/appointment_detail/presantaion/widgets/status_chip.dart';
import 'package:intl/intl.dart';

class StickyPatientHeader extends StatelessWidget {
  final String patientName;
  final String patientAgeGender;
  final DateTime appointmentTime;
  final String appointmentStatus;
  final String patientImageUrl;
  final VoidCallback? onBackPressed;

  const StickyPatientHeader({
    super.key,
    required this.patientName,
    required this.patientAgeGender,
    required this.appointmentTime,
    required this.appointmentStatus,
    required this.patientImageUrl,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      automaticallyImplyLeading: false, // Remove default back button
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double maxExtent = 220.0;
          final double minExtent = kToolbarHeight + topPadding + 8;
          final double shrinkOffset = (maxExtent - constraints.maxHeight).clamp(
            0,
            maxExtent,
          );
          final double t = (shrinkOffset / (maxExtent - minExtent - 10)).clamp(
            0.0,
            1.0,
          );

          // Interpolated values for smooth transitions
          final double avatarSize =
              (80 * (1 - t)) + (32 * t); // shrink from 80 to 32
          final double nameOpacity = t;

          // Calculate avatar position - move from center to left
          final double screenWidth = MediaQuery.of(context).size.width;
          final double avatarCenterX = screenWidth / 2; // Center position
          final double avatarLeftX =
              16 +
              32 +
              22; // Left position (16 padding + 32 arrow width + 8 spacing)
          final double avatarX = avatarCenterX * (1 - t) + avatarLeftX * t;

          // Calculate avatar Y position - move from bottom to top
          final double avatarCenterY = 120; // Center Y in expanded state
          final double avatarTopY =
              topPadding + 12 + (avatarSize / 2); // Top Y in collapsed state
          final double avatarY = avatarCenterY * (1 - t) + avatarTopY * t;

          return Stack(
            children: [
              // Static content that fades out (name, status, time)
              Opacity(
                opacity: 1 - t,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding:  EdgeInsets.zero,
                    child: ListView(
                      padding: EdgeInsets.only(top: 80),
                      children: [
                        SizedBox(height: avatarSize), // Space for moving avatar
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            "$patientName, $patientAgeGender",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          
                          children: [
                            StatusChip(status: appointmentStatus),
                            const SizedBox(width: 8),
                            Text(
                              "${DateFormat('hh:mm a').format(appointmentTime)}, Today",
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Moving Avatar - single avatar that moves from center to left
              Positioned(
                left:
                    avatarX -
                    (avatarSize / 2), // Center the avatar on its position
                top: avatarY - (avatarSize / 2),
                child: CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundImage: patientImageUrl.isNotEmpty
                      ? CachedNetworkImageProvider(patientImageUrl)
                      : null,
                  child: patientImageUrl.isEmpty
                      ? Text(
                          patientName.isNotEmpty
                              ? patientName[0].toUpperCase()
                              : "?",
                          style: TextStyle(
                            fontSize:
                                avatarSize *
                                0.4, // avatar ke size ke hisaab se font size
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
              GestureDetector(
                onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                child: Padding(
                  padding: EdgeInsetsGeometry.only(top: minExtent / 1.8),
                  child: Container(
                    width: 32,
                    height: 32,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                ),
              ),
              // Back arrow and patient name (appears when collapsed)
              if (t > 0.2)
                Positioned(
                  left: 16,
                  top: minExtent / 1.8,

                  child: Row(
                    children: [
                      // Back arrow
                      SizedBox(
                        width: screenWidth / 3,
                      ), // Space for arrow + avatar
                      // Patient name (only visible when collapsed)
                      Opacity(
                        opacity: nameOpacity,
                        child: Text(
                          patientName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),

                      // Status chip
                    ],
                  ),
                ),
              if (t > 0.2)
                Positioned(
                  top: minExtent / 1.8,

                  right: 0,
                  child: Transform.scale(
                    scale: 0.85,
                    child: StatusChip(status: appointmentStatus),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
