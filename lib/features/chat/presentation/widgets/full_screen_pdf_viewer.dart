import 'package:flutter/material.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';

class FullScreenPdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String? pdfName;

  const FullScreenPdfViewer({
    super.key,
    required this.pdfUrl,
    this.pdfName = 'Document',
  });

  @override
  State<FullScreenPdfViewer> createState() => _FullScreenPdfViewerState();
}

class _FullScreenPdfViewerState extends State<FullScreenPdfViewer> {
  // The controller is the only state we need to manage.
  late final PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    // <<<--- THE FIX IS HERE ---
    // Pass the Future directly to the controller's constructor.
    // The controller and PdfView will handle the loading state internally.
    _pdfController = PdfController(
      document: PdfDocument.openData(
        // Add a timeout for safety
        InternetFile.get(widget.pdfUrl).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            // This will throw a TimeoutException, which the PdfView will catch
            throw Exception('PDF failed to load in 30 seconds.');
          },
        ),
      ),
    );
    // <<<-------------------->>>
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pdfName!),
        actions: [
          // The page number widget needs the controller
          PdfPageNumber(
            controller: _pdfController,
            builder: (_, state, page, pagesCount) => Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '$page/${pagesCount ?? 0}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      // The PdfView widget is smart. It will show its own loading indicator
      // while the controller's 'document' future is completing.
      body: PdfView(
        controller: _pdfController,
        // Optional: You can provide a custom builder for different states
        builders: PdfViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          pageLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
