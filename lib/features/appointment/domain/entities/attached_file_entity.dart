import 'package:equatable/equatable.dart';

/// Represents a file attached to an appointment (e.g., lab report, X-ray).
class AttachedFileEntity extends Equatable {
  final String fileName;
  final String url; // Download URL from Firebase Storage

  const AttachedFileEntity({
    required this.fileName,
    required this.url,
  });

  @override
  List<Object?> get props => [fileName, url];
}