import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/core/di/service_locator.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_bloc.dart';
import 'package:health_connect/features/auth/presentation/auth/blocs/auth_state.dart';
import 'package:health_connect/features/chat/domain/entities/message_entity.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_bloc.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_event.dart';
import 'package:health_connect/features/chat/presentation/blocs/chat_room/chat_room_state.dart';
import 'package:health_connect/features/doctor/doctor_profile_setup/domain/entity/doctor_profile_entity.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends StatelessWidget {
  final String chatRoomId;
  final String chatPartnerName;
  final String receiverId;
  final UserEntity patient; // <<<--- NEW
  final DoctorEntity doctor; // <<<--- NEW

  const ChatRoomScreen({
    super.key,
    required this.chatRoomId,
    required this.chatPartnerName,
    required this.receiverId,
    required this.patient, // <<<--- NEW
    required this.doctor, // <<<--- NEW
  });

  @override
  Widget build(BuildContext context) {
    String currentUserId = '';
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedPatient) {
      currentUserId = authState.user.id;
    } else if (authState is AuthenticatedDoctorProfileExists) {
      currentUserId = authState.user.id;
    } else if (authState is AuthenticatedDoctorProfileNotExists) {
      currentUserId = authState.user.id;
    }
    return BlocProvider(
      create: (context) => sl<ChatRoomBloc>()
        ..add(
          SubscribeToMessages(chatRoomId),
        ), // Subscribe to messages as soon as the BLoC is created
      child: Scaffold(
        appBar: AppBar(
          title: Text(chatPartnerName),
          actions: [
            IconButton(
              icon: const Icon(Icons.videocam_outlined),
              onPressed: () {
                // TODO: Implement video call
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // --- Message List ---
            Expanded(
              child: BlocBuilder<ChatRoomBloc, ChatRoomState>(
                builder: (context, state) {
                  if (state is ChatRoomLoading || state is ChatRoomInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ChatRoomError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is ChatRoomLoaded) {
                    if (state.messages.isEmpty) {
                      return const Center(
                        child: Text("No messages yet. Say hello!"),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      reverse: true, // This is key for chat UIs
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final bool isMe = message.senderId == currentUserId;
                        return MessageBubble(message: message, isMe: isMe);
                      },
                    );
                  }
                  // This will catch other states like MessageSending etc.
                  // Or you can handle them explicitly. For now, we show the loaded messages.
                  if (state is ChatRoomLoaded) {
                    return const Center(child: Text("Something went wrong"));
                  }
                  // Fallback
                  return const SizedBox.shrink();
                },
              ),
            ),
            // --- Chat Input Field ---
            // Pass the necessary IDs to the input field
            ChatInputField(
              chatRoomId: chatRoomId,
              receiverId: receiverId,
              doctor: doctor,
              patient: patient,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widget for the input field at the bottom ---
class ChatInputField extends StatefulWidget {
  final String chatRoomId;
  final String receiverId;
  final UserEntity patient; // <<<--- NEW
  final DoctorEntity doctor; // <<<--- NEW

  const ChatInputField({
    super.key,
    required this.chatRoomId,
    required this.receiverId,
    required this.doctor,
    required this.patient,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // <<<--- THE MODIFIED _sendMessage METHOD ---
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return; // Don't send empty messages
    }

    // Get the current user's ID to determine the sender
    final authState = context.read<AuthBloc>().state;
    String? senderId;
    if (authState is AuthenticatedPatient) {
      senderId = authState.user.id;
    } else if (authState is AuthenticatedDoctorProfileExists) {
      senderId = authState.user.id;
    } else if (authState is AuthenticatedDoctorProfileNotExists) {
      senderId = authState.user.id;
    }

    if (senderId == null) {
      // Show an error if the user is not properly authenticated
      print("Please login");
      return;
    }

    // Create the message entity
    final message = MessageEntity(
      id: '', // Firestore will generate this
      senderId: senderId,
      receiverId: widget.receiverId,
      content: text,
      type: 'text',
      timestamp: Timestamp.now(),
    );

    // Dispatch the updated event with all the required data
    context.read<ChatRoomBloc>().add(
      SendMessage(
        widget.chatRoomId,
        message,
        widget.doctor, // Pass the doctor entity
        widget.patient, // Pass the patient entity
      ),
    );

    // Clear the text field and unfocus
    _messageController.clear();
    FocusScope.of(context).unfocus();
  }

  // <<<--- END OF MODIFICATION ---
  void _showAttachmentPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick Image from Gallery'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the sheet
                  _pickAndSendFile('image');
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Pick Document (PDF)'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the sheet
                  _pickAndSendFile('pdf');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- NEW METHOD TO HANDLE FILE PICKING AND SENDING ---
  Future<void> _pickAndSendFile(String type) async {
    File? file;

    if (type == 'image') {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        file = File(pickedFile.path);
      }
    } else if (type == 'pdf') {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        file = File(result.files.single.path!);
      }
    }

    if (file != null) {
      // Dispatch the SendFileMessage event
      context.read<ChatRoomBloc>().add(
        SendFileMessage(
          chatRoomId: widget.chatRoomId,
          receiverId: widget.receiverId,
          file: file,
          messageType: type,
          patient: widget.patient,
          doctor: widget.doctor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
    // A subtle top border to separate the input field from the messages
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Attach Icon
            IconButton(
              icon: Icon(Icons.attach_file_rounded, color: theme.colorScheme.outline),
              onPressed: _showAttachmentPicker,
            ),
            
            // Text Field
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  // Use the main background color for a nice contrast
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  // Remove all borders
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24), // Makes it pill-shaped
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
             BlocBuilder<ChatRoomBloc, ChatRoomState>(
      builder: (context, state) {
        if (state is MessageSending) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 12),
                Text("Uploading attachment..."),
              ],
            ),
          );
        }
        return const SizedBox.shrink(); // Hide if not sending
      },
    ),
            // Send Button
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.all(12),
              ),
              icon: const Icon(Icons.send_rounded),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    ),);

  }
}

// --- Helper Widget for a single chat bubble ---
class MessageBubble extends StatelessWidget {
  final MessageEntity message; // Now takes the full entity
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Format the timestamp
    final time = DateFormat('hh:mm a').format(message.timestamp.toDate());

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        // ... (decoration is the same)
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? theme.colorScheme.primary
              : theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe
                ? const Radius.circular(16)
                : const Radius.circular(0),
            bottomRight: isMe
                ? const Radius.circular(0)
                : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // The message content
            Text(
              message.content,
              style: TextStyle(
                color: isMe
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            // The timestamp
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color:
                    (isMe
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSecondaryContainer)
                        .withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
