
// --- MESSAGE BUBBLE WIDGET ---
import 'package:flutter/material.dart';
import 'package:health_connect/features/chat/domain/entities/message_entity.dart';
import 'package:health_connect/features/chat/presentation/widgets/message_content.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';

class MessageBubble extends StatefulWidget {
  final MessageEntity message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>  {
  PdfController? _pdfController;
  @override

  @override
  void initState() {
    super.initState();
    // Initialize the PDF controller only if the message is a PDF and has a URL
    if (widget.message.type == 'pdf' && widget.message.fileUrl != null) {
      _initPdfController();
    }
  }

  void _initPdfController() async {
    try {
      // Use openData with InternetFile.get to load the PDF from the URL
      _pdfController = PdfController(
        document: PdfDocument.openData(
          InternetFile.get(widget.message.fileUrl!),
        ),
      );
      // Rebuild the widget once the controller is ready
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error loading PDF preview: $e");
      // Optionally handle the error in the UI by setting a flag
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: widget.isMe
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.all(12.0),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: widget.isMe
                ? theme.colorScheme.primary
                : theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: widget.isMe
                  ? const Radius.circular(16)
                  : const Radius.circular(0),
              bottomRight: widget.isMe
                  ? const Radius.circular(0)
                  : const Radius.circular(16),
            ),
          ),
          child: MessageContentWidget(
            message: widget.message,
            isMe: widget.isMe,
            pdfController: _pdfController,
            status:widget.message.status

          ),
        ),
        SizedBox(width: 8),
      ],
    );
  }

}
