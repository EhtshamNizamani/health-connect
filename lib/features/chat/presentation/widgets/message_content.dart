import 'package:flutter/material.dart';
import 'package:health_connect/core/constants/app_color.dart';
import 'package:health_connect/core/shared/widgets/full_screen_image_view.dart';
import 'package:health_connect/features/chat/domain/entities/message_entity.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pdfx/pdfx.dart';
import 'full_screen_pdf_viewer.dart'; // Naya full screen viewer widget import karein

class MessageContentWidget extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final MessageStatus status;

  final PdfController? pdfController;

  const MessageContentWidget({
    super.key,
    required this.message,
    required this.isMe,
    required this.status,
    this.pdfController, // PdfController optional hai
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = DateFormat('hh:mm a').format(message.timestamp.toDate());
    final textColor = isMe
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSecondaryContainer;

    switch (message.type) {
      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                if (message.fileUrl != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FullScreenImageViewer(imageUrl: message.fileUrl!),
                    ),
                  );
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Hero(
                  tag: message.fileUrl!,
                  child: CachedNetworkImage(
                    imageUrl: message.fileUrl ?? '',
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _MessageStatusIndicator(
                    status: status,
                    color: textColor.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        );

      case 'pdf':
        return InkWell(
          onTap: () {
            if (message.fileUrl != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenPdfViewer(
                    pdfUrl: message.fileUrl!,
                    pdfName: 'Document',
                  ),
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pdfController != null)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                            color: textColor.withAlpha(153), // 0.7 * 255 = 178.5 ≈ 179
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: PdfView(
                      controller: pdfController!,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(color: textColor),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                            color: textColor.withAlpha(179), // 0.7 * 255 = 178.5 ≈ 179
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _MessageStatusIndicator(
                          status: status,
                            color: textColor.withAlpha(179), // 0.7 * 255 = 178.5 ≈ 179
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.picture_as_pdf_rounded, color: textColor),
                      const SizedBox(width: 8),
                      Text(
                        'Document.pdf', // Placeholder name
                        style: TextStyle(color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

      case 'text':
      default:
        return Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.content, style: TextStyle(color: textColor)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _MessageStatusIndicator(
                    status: status,
                    color: textColor.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        );
    }
  }

  // <<<--- NEW HELPER WIDGET FOR THE STATUS ICON ---
  Widget _MessageStatusIndicator({
    required MessageStatus status,
    required Color color,
  }) {
    switch (status) {
      case MessageStatus.sending:
        // A simple clock icon for 'sending'
        return Icon(Icons.watch_later_outlined, size: 14, color: color);
      case MessageStatus.failed:
        // An error icon for 'failed'
        return Icon(Icons.error_outline, color: AppColors.error, size: 14);
      case MessageStatus.sent:
      default:
        // A single check for 'sent'. You can expand this later
        // to include a double check for 'seen' if you implement that feature.
        return Icon(Icons.done, size: 14, color: color);
    }
  }
}
