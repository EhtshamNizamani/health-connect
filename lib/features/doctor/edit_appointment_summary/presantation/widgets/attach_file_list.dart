
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_connect/features/appointment/domain/entities/attached_file_entity.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/presantation/widgets/add_button.dart';
import 'package:health_connect/features/doctor/edit_appointment_summary/presantation/widgets/file_preview_card.dart';
import 'package:pdfx/pdfx.dart';

class AttachedFilesList extends StatelessWidget {
  /// Files that are already uploaded and have a URL.
  final List<AttachedFileEntity> existingFiles;

  /// New local files that have been picked by the user.
  final List<File> newlyPickedFiles;

  final VoidCallback onAddFile;
  final Function(File) onDeleteNewlyPickedFile;
  final Function(AttachedFileEntity) onDeleteExistingFile;

  const AttachedFilesList({
    super.key,
    required this.existingFiles,
    required this.newlyPickedFiles,
    required this.onAddFile,
    required this.onDeleteNewlyPickedFile,
    required this.onDeleteExistingFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (existingFiles.isEmpty && newlyPickedFiles.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text("No files attached yet."),
          ),

        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: existingFiles.length + newlyPickedFiles.length + 1, // +1 for the add button
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // The last item is always the "Add File" button
            if (index == existingFiles.length + newlyPickedFiles.length) {
              return AddButton(
                label: "Upload File",
                onTap: onAddFile,
              );
            }
            
            // Display existing files first
            if (index < existingFiles.length) {
              final file = existingFiles[index];
              return FilePreviewCard(
                fileName: file.fileName,
                onDelete: () => onDeleteExistingFile(file),
                previewWidget: _buildNetworkPreview(file.url), 
              );
            }
            
            // Display newly picked files
            final newlyPickedIndex = index - existingFiles.length;
            final file = newlyPickedFiles[newlyPickedIndex];
            return FilePreviewCard(
              // <<< --- THE FIX: Get file name from the File path ---
              fileName: file.path.split('/').last,
              onDelete: () => onDeleteNewlyPickedFile(file),
              previewWidget: _buildLocalFilePreview(file), 
            );
          },
        ),
      ],
    );
  }
}


// --- FILE-LEVEL HELPER FUNCTIONS (Keeps the widget class clean) ---

Widget _buildLocalFilePreview(File file) {
  final isImage = ['jpg', 'jpeg', 'png'].contains(file.path.split('.').last.toLowerCase());
  
  if (isImage) {
    return Image.file(file, fit: BoxFit.cover,
      // Add an error builder for robustness
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.red));
      },
    );
  } else {
    // PDF thumbnail
    return FutureBuilder<PdfPageImage?>(
      future: _renderPdfThumbnail(file.path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
          return Image.memory(snapshot.data!.bytes, fit: BoxFit.contain);
        }
        return Center(
          child: Icon(CupertinoIcons.doc_text_fill, size: 40, color: Colors.grey.shade600),
        );
      },
    );
  }
}

Future<PdfPageImage?> _renderPdfThumbnail(String filePath) async {
  try {
    final doc = await PdfDocument.openFile(filePath);
    final page = await doc.getPage(1);
    final pageImage = await page.render(width: 200, height: 300);
    await page.close();
    await doc.close();
    return pageImage;
  } catch (e) {
    print("Error rendering PDF thumbnail: $e");
    return null;
  }
}

Widget _buildNetworkPreview(String url) {
   final isImage = ['jpg', 'jpeg', 'png'].any((ext) => url.toLowerCase().contains(ext));
   if(isImage) {
     return Image.network(url, fit: BoxFit.cover, 
      loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.red));
      },
     );
   } else {
     return Center(child: Icon(CupertinoIcons.doc_text_fill, size: 40, color: Colors.grey.shade600));
   }
}