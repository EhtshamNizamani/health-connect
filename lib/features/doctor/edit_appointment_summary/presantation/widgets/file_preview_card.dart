

import 'package:flutter/material.dart';

class FilePreviewCard extends StatelessWidget {
  final String fileName;
  final VoidCallback onDelete;
  final Widget previewWidget;

  const FilePreviewCard({super.key, 
    required this.fileName,
    required this.onDelete,
    required this.previewWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Stack(
        children: [
          // The preview
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: previewWidget,
            ),
          ),
          // The file name overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(11),
                  bottomRight: Radius.circular(11),
                ),
              ),
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          // The delete button
          Positioned(
            top: -8,
            right: -8,
            child: IconButton(
              icon: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}


// --- Helper Widgets ---
